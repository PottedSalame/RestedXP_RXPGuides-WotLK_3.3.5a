"""Installed-browser acceptance of committed interior artwork and editor actions."""
import argparse
import base64
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import threading
import time
import urllib.request
import serve
from browser_maps import DevTools


def run(browser, output, prefix='/', site_root=None):
    output=output.resolve();output.mkdir(parents=True,exist_ok=True)
    profile=Path(tempfile.mkdtemp(prefix='interior-browser-',dir=output))
    if site_root:serve.ROOT=site_root.resolve()
    httpd=serve.server(0,prefix);thread=threading.Thread(target=httpd.serve_forever,daemon=True);thread.start()
    process=None;client=None;success=False
    try:
        process=subprocess.Popen([str(browser),'--headless','--disable-gpu','--no-first-run','--disable-background-networking',
            '--disable-component-update','--disable-sync','--disable-extensions','--user-data-dir='+str(profile),
            '--remote-debugging-port=0','--remote-debugging-address=127.0.0.1','--window-size=1400,1100','about:blank'],
            stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        portfile=profile/'DevToolsActivePort'
        for _ in range(100):
            if portfile.exists():break
            time.sleep(.1)
        port=int(portfile.read_text().splitlines()[0])
        pages=json.load(urllib.request.urlopen(f'http://127.0.0.1:{port}/json/list'))
        client=DevTools(next(p['webSocketDebuggerUrl'] for p in pages if p['type']=='page'))
        client.call('Page.enable')
        client.call('Emulation.setDeviceMetricsOverride',dict(width=1400,height=1100,deviceScaleFactor=2,mobile=False))
        client.call('Page.addScriptToEvaluateOnNewDocument',dict(source="""
          window.interiorAudit={requests:[],errors:[],draws:0};
          const original=window.fetch;window.fetch=function(url,options){interiorAudit.requests.push(String(url));return original.call(this,url,options);};
          addEventListener('error',e=>interiorAudit.errors.push(e.message));
          addEventListener('unhandledrejection',e=>interiorAudit.errors.push(String(e.reason)));
          const draw=CanvasRenderingContext2D.prototype.drawImage;
          CanvasRenderingContext2D.prototype.drawImage=function(...args){if(this.canvas.id==='interior-canvas')interiorAudit.draws++;return draw.apply(this,args);};
        """))
        client.call('Page.navigate',dict(url=f'http://127.0.0.1:{httpd.server_port}{prefix}guide-editor/'))
        def evaluate(code):
            result=client.call('Runtime.evaluate',dict(expression=code,awaitPromise=True,returnByValue=True))
            if 'exceptionDetails' in result:raise RuntimeError(result['exceptionDetails'].get('exception',{}).get('description','Browser script failed'))
            return result['result'].get('value')
        for _ in range(100):
            if evaluate("!!document.getElementById('map-kind')&&!!document.getElementById('source').value"):break
            time.sleep(.1)
        result=evaluate(r"""(async()=>{
          const $=id=>document.getElementById(id),sleep=ms=>new Promise(r=>setTimeout(r,ms)),check=(v,m)=>{if(!v)throw Error(m);};
          const until=async(fn)=>{for(let i=0;i<100;i++){if(fn())return;await sleep(100);}throw Error('Timed out: '+$('interior-status').textContent);};
          check(!interiorAudit.requests.some(p=>p.includes('/interiors/')),'Eager interior fetch');
          $('map-kind').value='dungeons';$('terrain-panel').open=true;
          await until(()=>$('interior-region').options.length===51);
          const select=async(kind,id)=>{
            $('map-kind').value=kind;$('map-kind').dispatchEvent(new Event('change'));
            $('interior-region').value=id;$('interior-region').dispatchEvent(new Event('change'));
            const prior=interiorAudit.draws;$('interior-canvas').scrollIntoView({block:'center'});
            await until(()=>interiorAudit.draws>prior&&$('interior-status').textContent.includes('view-only'));
            await sleep(200);return {region:$('interior-region').selectedOptions[0].textContent,sections:$('interior-view').options.length,entities:$('interior-count').textContent};
          };
          const original=$('source').value,results=[];
          for(const [kind,id] of [['dungeons','map-389'],['dungeons','map-43'],['dungeons','map-230'],['raids','map-631'],['underground','map-369']])results.push(await select(kind,id));
          const cave=[...$('interior-region').options].find(o=>o.value.startsWith('wmo-'));check(cave,'No cave regions');
          results.push(await select('underground',cave.value));
          check($('interior-entities').options.length===0,'Shared cave borrowed outdoor entities');
          check($('source').value===original,'Browsing changed source');
          await select('dungeons','map-619');
          $('interior-view').value='a7a8c92678992446-0';$('interior-view').dispatchEvent(new Event('change'));
          const largeStart=interiorAudit.requests.length;await sleep(1200);
          const largeSettled=interiorAudit.requests.length;await sleep(700);
          check(largeSettled===interiorAudit.requests.length,'Large overview keeps fetching while idle');
          check(largeSettled-largeStart<100,'Large sheet exceeded bounded overview work');
          await select('dungeons','map-43');
          $('interior-type').value='npcs';$('interior-type').dispatchEvent(new Event('change'));
          await until(()=>$('interior-entities').options.length>0);
          $('interior-entities').selectedIndex=0;$('interior-entity-details').click();
          const add=[...$('interior-details').querySelectorAll('button')].find(b=>b.textContent==='Add target');check(add,'Missing target action');add.click();
          check($('source').value!==original&&/\.target \d+/.test($('source').value),'Target did not reach source');
          $('undo').click();check($('source').value===original,'Interior action did not undo');
          const c=$('interior-canvas');for(const key of ['ArrowLeft','+','-','Escape'])c.dispatchEvent(new KeyboardEvent('keydown',{key,cancelable:true}));
          c.click();await sleep(250);check($('source').value===original,'Image navigation created instructions');
          const before=interiorAudit.requests.length;$('terrain-panel').open=false;await sleep(250);
          const settled=interiorAudit.requests.length;await sleep(350);check(interiorAudit.requests.length===settled,'Fetch while collapsed');
          check(!interiorAudit.errors.length,interiorAudit.errors.join(';'));
          $('terrain-panel').open=true;await sleep(250);c.scrollIntoView({block:'center'});
          return {status:'passed',regions:results,requests:interiorAudit.requests.length,draws:interiorAudit.draws};
        })()""")
        client.call('Emulation.setDeviceMetricsOverride',dict(width=375,height=800,deviceScaleFactor=2,mobile=False))
        time.sleep(.2)
        narrow=evaluate("(()=>{const c=document.getElementById('interior-canvas').getBoundingClientRect();return Math.abs(c.width-c.height)<2&&document.documentElement.scrollWidth<=document.documentElement.clientWidth+2;})()")
        if not narrow:raise RuntimeError('Narrow interior controls overflow')
        client.call('Emulation.setDeviceMetricsOverride',dict(width=1400,height=1100,deviceScaleFactor=1,mobile=False))
        time.sleep(.3)
        (output/'interior.png').write_bytes(base64.b64decode(client.call('Page.captureScreenshot',dict(format='png'))['data']))
        (output/'result.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
        print(json.dumps(result));success=True
    finally:
        if client:client.socket.close()
        if process:process.terminate();process.wait(timeout=15)
        httpd.shutdown();httpd.server_close();thread.join()
        if success:
            if profile.parent!=output or profile.is_symlink() or profile.is_junction():raise RuntimeError('Unsafe test cleanup')
            shutil.rmtree('\\\\?\\'+str(profile) if __import__('os').name=='nt' else profile)


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--browser',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--prefix',default='/');parser.add_argument('--site-root',type=Path)
    args=parser.parse_args();run(args.browser,args.output,args.prefix,args.site_root)
