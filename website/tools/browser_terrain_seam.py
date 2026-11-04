"""Local before/after Ghostlands rendering test using the installed browser."""
import argparse
import base64
import json
from pathlib import Path
import subprocess
import tempfile
import threading
import time
import urllib.request

import serve
from browser_maps import DevTools


def run(browser, output, prefix='/', site_root=None):
    output=output.resolve();output.mkdir(parents=True,exist_ok=True)
    if site_root:serve.ROOT=site_root.resolve()
    httpd=serve.server(0,prefix)
    thread=threading.Thread(target=httpd.serve_forever,daemon=True);thread.start()
    try:
        with tempfile.TemporaryDirectory(prefix='rxp-seam-') as folder:
            profile=Path(folder)
            process=subprocess.Popen([str(browser),'--headless','--disable-gpu','--no-first-run',
                '--disable-background-networking','--disable-component-update','--disable-sync','--disable-extensions',
                '--user-data-dir='+folder,'--remote-debugging-port=0','--remote-debugging-address=127.0.0.1','about:blank'],
                stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
            client=None
            try:
                for _ in range(100):
                    if (profile/'DevToolsActivePort').exists():break
                    time.sleep(.1)
                port=int((profile/'DevToolsActivePort').read_text().splitlines()[0])
                pages=json.load(urllib.request.urlopen(f'http://127.0.0.1:{port}/json/list'))
                client=DevTools(next(p['webSocketDebuggerUrl'] for p in pages if p['type']=='page'))
                client.call('Page.enable')
                client.call('Emulation.setDeviceMetricsOverride',dict(width=1280,height=1100,deviceScaleFactor=1,mobile=False))
                def evaluate(code):
                    value=client.call('Runtime.evaluate',dict(expression=code,awaitPromise=True,returnByValue=True))
                    if 'exceptionDetails' in value:raise RuntimeError(value['exceptionDetails'])
                    return value['result'].get('value')
                results={}
                for mode in ('original','cleaned'):
                    hook=r'''window.seam={active:0,decoding:0,peak:0,cleaned:0};
                      const realFetch=window.fetch;window.fetch=async(...args)=>{
                        const key=String(args[0]);
                        if(BLOCK && key.endsWith('/terrain-cleanup/manifest.json'))return new Response('',{status:404});
                        seam.active++;seam.peak=Math.max(seam.peak,seam.active);
                        if(key.includes('/terrain-cleanup/')&&key.endsWith('.webp'))seam.cleaned++;
                        try{return await realFetch(...args);}finally{seam.active--;}
                      };
                      const bitmap=window.createImageBitmap;window.createImageBitmap=async(...args)=>{
                        seam.decoding++;try{return await bitmap(...args);}finally{seam.decoding--;}
                      };'''.replace('BLOCK','true' if mode=='original' else 'false')
                    script=client.call('Page.addScriptToEvaluateOnNewDocument',dict(source=hook))['identifier']
                    client.call('Page.navigate',dict(url=f'http://127.0.0.1:{httpd.server_port}{prefix}guide-editor/'))
                    time.sleep(.3)
                    evaluate(r'''(async()=>{
                      const sleep=ms=>new Promise(r=>setTimeout(r,ms));
                      for(let i=0;i<100&&!document.getElementById('source');i++)await sleep(50);
                      const source=document.getElementById('source');
                      source.value='#wotlk\n#ac335\n#group RXPGuides Custom Guides\n#name Terrain seam test\nstep\n .goto Ghostlands,50,100,60,0 >>Unchanged << Horde\n';
                      source.dispatchEvent(new Event('input',{bubbles:true}));await sleep(300);
                      document.getElementById('terrain-panel').open=true;
                      for(let i=0;i<100&&document.getElementById('map-content').hidden;i++)await sleep(100);
                      if(document.getElementById('map-content').hidden)throw new Error('Map did not open');
                      const select=(id,value)=>{const e=document.getElementById(id);e.value=value;e.dispatchEvent(new Event('change'));};
                      select('map-continent',0);select('map-zone',463);select('map-waypoints','1');
                      for(const input of document.querySelectorAll('[data-layer]'))if(input.checked&&input.dataset.layer!=='guide')input.click();
                      document.getElementById('map-out').click();
                      window.seamSource=source.value;
                    })()''')
                    results[mode]=[]
                    for level in range(3):
                        if level:evaluate("document.getElementById('map-in').click()")
                        sample=evaluate(r'''(async()=>{
                          const sleep=ms=>new Promise(r=>setTimeout(r,ms));await sleep(600);
                          for(let i=0;i<100&&(seam.active||seam.decoding);i++)await sleep(100);await sleep(200);
                          const canvas=document.getElementById('terrain');canvas.scrollIntoView({block:'center'});
                          const p=canvas.getContext('2d').getImageData(0,0,canvas.width,canvas.height).data;
                          let navy=0,white=0;
                          for(let i=0;i<p.length;i+=4){
                            if((p[i]===33&&p[i+1]===36&&p[i+2]===58)||(p[i]===29&&p[i+1]===34&&p[i+2]===53))navy++;
                            if(p[i]===247&&(p[i+1]===245||p[i+1]===247)&&p[i+2]===247)white++;
                          }
                          if(document.getElementById('source').value!==seamSource)throw new Error('View changed source');
                          const r=canvas.getBoundingClientRect();
                          return {navy,white,peak:seam.peak,cleaned:seam.cleaned,clip:{x:r.x+scrollX,y:r.y+scrollY,width:r.width,height:r.height,scale:1}};
                        })()''')
                        image=client.call('Page.captureScreenshot',dict(format='png',clip=sample.pop('clip'),captureBeyondViewport=True))['data']
                        (output/f'{mode}-{level}.png').write_bytes(base64.b64decode(image))
                        results[mode].append(sample)
                    client.call('Page.removeScriptToEvaluateOnNewDocument',dict(identifier=script))
                for before,after in zip(results['original'],results['cleaned']):
                    if not after['cleaned'] or after['peak']>4:raise RuntimeError('Cleanup not painted or unbounded requests')
                    if before['navy']+before['white']<1000:raise RuntimeError('Control did not reproduce blank border')
                    if after['navy']+after['white']>(before['navy']+before['white'])*.1:raise RuntimeError('Blank border remains')
                (output/'result.json').write_text(json.dumps(results,indent=2)+'\n')
                print('Ghostlands seam: three zoom levels passed; source unchanged; request peak <=4.')
            finally:
                if client:client.socket.close()
                process.terminate();process.wait(timeout=15)
    finally:
        httpd.shutdown();httpd.server_close();thread.join()


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('browser','output'):parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--prefix',default='/');parser.add_argument('--site-root',type=Path)
    args=parser.parse_args();run(args.browser,args.output,args.prefix,args.site_root)
