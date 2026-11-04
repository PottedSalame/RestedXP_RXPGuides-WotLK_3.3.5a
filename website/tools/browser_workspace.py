"""Native local browser smoke checks and screenshots for the editing workspace."""
import argparse
import base64
import json
import os
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
    profile=Path(tempfile.mkdtemp(prefix='workspace-browser-',dir=output))
    if site_root:serve.ROOT=site_root.resolve()
    httpd=serve.server(0,prefix);thread=threading.Thread(target=httpd.serve_forever,daemon=True);thread.start()
    client=None;process=None;success=False
    try:
        process=subprocess.Popen([str(browser),'--headless','--disable-gpu','--no-first-run','--disable-background-networking',
            '--disable-component-update','--disable-sync','--disable-extensions','--user-data-dir='+str(profile),
            '--remote-debugging-port=0','--remote-debugging-address=127.0.0.1','about:blank'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        portfile=profile/'DevToolsActivePort'
        for _ in range(100):
            if portfile.exists():break
            time.sleep(.1)
        port=int(portfile.read_text().splitlines()[0]);pages=json.load(urllib.request.urlopen(f'http://127.0.0.1:{port}/json/list'))
        client=DevTools(next(p['webSocketDebuggerUrl'] for p in pages if p['type']=='page'))
        client.call('Page.enable');client.call('Emulation.setDeviceMetricsOverride',dict(width=1440,height=1000,deviceScaleFactor=1,mobile=False))
        client.call('Page.addScriptToEvaluateOnNewDocument',dict(source="window.workspaceErrors=[];addEventListener('error',e=>workspaceErrors.push(e.message));addEventListener('unhandledrejection',e=>workspaceErrors.push(String(e.reason)));"))
        client.call('Page.navigate',dict(url=f'http://127.0.0.1:{httpd.server_port}{prefix}guide-editor/'))
        def evaluate(code):
            result=client.call('Runtime.evaluate',dict(expression=code,awaitPromise=True,returnByValue=True))
            if 'exceptionDetails' in result:raise RuntimeError(result['exceptionDetails'].get('exception',{}).get('description','Browser script failed'))
            return result['result'].get('value')
        for _ in range(100):
            if evaluate("document.body?.classList.contains('workspace-ready')&&document.getElementById('status').textContent==='Ready.'"):break
            time.sleep(.1)
        evaluate(r"""(async()=>{const s=document.getElementById('source');s.value='#wotlk\n#ac335\n#group RXPGuides Custom Guides\n#name Durotar test route\nstep\n    .accept 4641 >>Accept Your Place In The World\n    .target Kaltunk::10176\nstep\n    .goto Durotar,42.1,68.3\n    .turnin 4641 >>Turn in Your Place In The World\nstep\n    .accept 788 >>Accept Cutting Teeth\n';s.dispatchEvent(new Event('input',{bubbles:true}));await new Promise(r=>setTimeout(r,400));document.getElementById('display-text').focus();document.getElementById('display-text').select();})()""")
        client.call('Input.insertText',dict(text='Speak to Kaltunk and accept the quest.'));time.sleep(.1)
        if not evaluate("document.getElementById('source').value.includes('Speak to Kaltunk and accept the quest.')"):raise RuntimeError('Native typing did not update source')
        def screenshot(name):
            (output/(name+'.png')).write_bytes(base64.b64decode(client.call('Page.captureScreenshot',dict(format='png'))['data']))
        evaluate('window.scrollTo(0,0)');screenshot('write-wide')
        evaluate("document.getElementById('workspace-tabs-source').click();window.scrollTo(0,0)");screenshot('source-wide')
        for width in (1440,900,700,375):
            client.call('Emulation.setDeviceMetricsOverride',dict(width=width,height=900,deviceScaleFactor=1,mobile=False));time.sleep(.1)
            evaluate("document.getElementById('workspace-tabs-write').click();window.scrollTo(0,0)")
            for name in ('file-menu','export-menu'):
                visible=evaluate("(async()=>{const m=document.getElementById('"+name+"');m.open=true;await new Promise(r=>setTimeout(r,30));const r=m.querySelector('.command-content').getBoundingClientRect();return r.left>=0&&r.right<=innerWidth&&document.documentElement.scrollWidth<=document.documentElement.clientWidth+2;})()")
                if not visible:raise RuntimeError(f'{name} overflows at {width}')
                client.call('Input.dispatchKeyEvent',dict(type='keyDown',key='Escape',code='Escape',windowsVirtualKeyCode=27))
                client.call('Input.dispatchKeyEvent',dict(type='keyUp',key='Escape',code='Escape',windowsVirtualKeyCode=27))
                if evaluate("document.getElementById('"+name+"').open"):raise RuntimeError('Escape did not close menu')
            if width==375:screenshot('write-narrow')
        evaluate("document.getElementById('workspace-tabs-map').click()")
        for kind,canvas_id in (('outdoor','terrain'),('dungeons','interior-canvas')):
            evaluate("(()=>{const s=document.getElementById('map-kind');s.value="+json.dumps(kind)+";s.dispatchEvent(new Event('change',{bubbles:true}));})()")
            for _ in range(100):
                if evaluate("document.getElementById("+json.dumps(canvas_id)+").getBoundingClientRect().width>0"):break
                time.sleep(.1)
            for width,height in ((2560,900),(1440,720),(900,600),(375,800),(800,400)):
                client.call('Emulation.setDeviceMetricsOverride',dict(width=width,height=height,deviceScaleFactor=2,mobile=False));time.sleep(.15)
                result=evaluate("""(()=>{const c=document.getElementById(%s),r=c.getBoundingClientRect(),p=c.parentElement.getBoundingClientRect(),rem=parseFloat(getComputedStyle(document.documentElement).fontSize);
                    return r.width>0&&Math.abs(r.width-r.height)<=1&&r.height<=Math.max(12*rem,innerHeight-20*rem)+1&&
                        Math.abs((r.left+r.right)-(p.left+p.right))<=2&&document.documentElement.scrollWidth<=document.documentElement.clientWidth+2&&
                        Math.abs(c.width-r.width*2)<=2&&Math.abs(c.height-r.height*2)<=2;
                })()"""%json.dumps(canvas_id))
                if not result:raise RuntimeError(f'{kind} map is not bounded, square, centred or correctly scaled at {width}x{height}')
                if width==1440:
                    evaluate("document.getElementById('workspace-main').scrollIntoView({block:'start'})");screenshot(kind+'-bounded')
        print('Outdoor/interior map height, centring, square ratio and high-DPI resize passed at five viewport sizes.')
        errors=evaluate('workspaceErrors')
        if errors:raise RuntimeError(errors)
        # Keep the edited document open: its unsaved-work confirmation is valid.
        # Use a fresh browser tab for page-layout checks instead of bypassing it.
        target=client.call('Target.createTarget',dict(url='about:blank'))['targetId']
        pages=json.load(urllib.request.urlopen(f'http://127.0.0.1:{port}/json/list'))
        client.socket.close()
        client=DevTools(next(p['webSocketDebuggerUrl'] for p in pages if p['id']==target))
        client.call('Page.enable')
        for page in ('','help.html','credits.html','guide-editor/'):
            client.call('Page.navigate',dict(url=f'http://127.0.0.1:{httpd.server_port}{prefix}{page}'))
            for _ in range(100):
                if evaluate("location.pathname==="+json.dumps(prefix+page)+"&&document.readyState==='complete'"):break
                time.sleep(.1)
            for width,height in ((1440,1400),(375,900)):
                client.call('Emulation.setDeviceMetricsOverride',dict(width=width,height=height,deviceScaleFactor=1,mobile=False));time.sleep(.1)
                result=evaluate("""(()=>{const footers=document.querySelectorAll('body > footer'),main=document.querySelector('body > main');
                    if(footers.length!==1||!main)return false;
                    const f=footers[0].getBoundingClientRect(),m=main.getBoundingClientRect();
                    return f.top>=m.bottom-1&&f.bottom+scrollY>=innerHeight-1&&Math.abs(f.bottom+scrollY-document.documentElement.scrollHeight)<=2;
                })()""")
                if not result:raise RuntimeError(f'Footer overlaps content or does not end page: {page} at {width}')
        print('Single non-overlapping footer ends each page at desktop and narrow widths.')
        print('Workspace native typing, menus at 1440/900/700/375 widths, Escape and screenshots passed.')
        success=True
    finally:
        if client:client.socket.close()
        if process:process.terminate();process.wait(timeout=15)
        httpd.shutdown();httpd.server_close();thread.join()
        if success:
            if profile.parent!=output or profile.is_symlink() or profile.is_junction():raise RuntimeError('Unsafe scratch cleanup')
            def disappeared(function,path,error):
                if not isinstance(error,FileNotFoundError):raise error
            shutil.rmtree('\\\\?\\'+str(profile) if os.name=='nt' else profile,onexc=disappeared)


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--browser',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--prefix',default='/');parser.add_argument('--site-root',type=Path)
    args=parser.parse_args();run(args.browser,args.output,args.prefix,args.site_root)
