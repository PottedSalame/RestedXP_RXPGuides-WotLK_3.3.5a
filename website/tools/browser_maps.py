"""Optional local-artwork browser acceptance; installed Chrome/Edge only."""
import argparse
import json
from pathlib import Path
import subprocess
import shutil
import tempfile
import threading
import time
import base64
import os
import socket
import struct
import urllib.request
from urllib.parse import urlsplit
import serve

class DevTools:
    """Minimal loopback-only CDP transport for our disposable browser process."""
    def __init__(self,url):
        parts=urlsplit(url)
        if parts.scheme!='ws' or parts.hostname not in ('127.0.0.1','localhost'):
            raise ValueError('Only the local test browser is allowed')
        self.socket=socket.create_connection((parts.hostname,parts.port),timeout=60)
        key=base64.b64encode(os.urandom(16)).decode()
        self.socket.sendall((f'GET {parts.path} HTTP/1.1\r\nHost: {parts.hostname}:{parts.port}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n').encode())
        header=b''
        while not header.endswith(b'\r\n\r\n'):header+=self.socket.recv(1)
        if b' 101 ' not in header:raise RuntimeError('Local browser handshake failed')
        self.serial=0
    def read(self,n):
        data=b''
        while len(data)<n:
            chunk=self.socket.recv(n-len(data))
            if not chunk:raise RuntimeError('Test browser disconnected')
            data+=chunk
        return data
    def call(self,method,params=None):
        self.serial+=1
        data=json.dumps(dict(id=self.serial,method=method,params=params or {})).encode();n=len(data);mask=os.urandom(4)
        header=bytes([0x81,0x80|n]) if n<126 else bytes([0x81,0xfe])+struct.pack('>H',n) if n<65536 else bytes([0x81,0xff])+struct.pack('>Q',n)
        self.socket.sendall(header+mask+bytes(b^mask[i%4] for i,b in enumerate(data)))
        message=b''
        while True:
            first,second=self.read(2);length=second&127
            if length==126:length=struct.unpack('>H',self.read(2))[0]
            elif length==127:length=struct.unpack('>Q',self.read(8))[0]
            if length>32*1024*1024:raise RuntimeError('Oversized browser test response')
            if second&128:raise RuntimeError('Unexpected masked server frame')
            if first&15==8:raise RuntimeError('Test browser closed connection')
            message+=self.read(length)
            if not first&128:continue
            result=json.loads(message);message=b''
            if result.get('id')==self.serial:
                if 'error' in result:raise RuntimeError(result['error'])
                return result['result']

def run(browser,output,zone=None,prefix='/',scale=1,site_root=None):
    output=output.resolve();output.mkdir(parents=True,exist_ok=True)
    profile=Path(tempfile.mkdtemp(prefix='terrain-browser-',dir=output))
    if site_root:
        # Only the built payload and two explicitly allowlisted test files.
        tests=serve.ROOT/'tests';serve.ROOT=site_root.resolve()
        class PackagedHarness(serve.Handler):
            def do_GET(self):
                name=urlsplit(self.path).path
                for fixture in ('terrain.html','terrain.js'):
                    if name==prefix+'tests/'+fixture:
                        data=(tests/fixture).read_bytes().replace(b'map-assets-local/',b'map-assets/')
                        self.send_response(200);self.send_header('Content-Type','text/javascript' if fixture.endswith('.js') else 'text/html; charset=utf-8')
                        self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data);return
                super().do_GET()
        serve.Handler=PackagedHarness
    httpd=serve.server(0,prefix);thread=threading.Thread(target=httpd.serve_forever,daemon=True);thread.start()
    success=False
    try:
        from urllib.parse import urlencode
        url=f'http://127.0.0.1:{httpd.server_port}{prefix}tests/terrain.html'+('?' + urlencode({'zone':zone}) if zone else '')
        command=[str(browser),'--headless','--disable-gpu','--no-first-run','--disable-background-networking',
            '--disable-component-update','--disable-sync','--disable-extensions','--user-data-dir='+str(profile),
            '--remote-debugging-port=0','--remote-debugging-address=127.0.0.1','--window-size=1400,1100','about:blank']
        process=subprocess.Popen(command,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        client=None
        try:
            portfile=profile/'DevToolsActivePort'
            for _ in range(100):
                if portfile.exists():break
                time.sleep(.1)
            port=int(portfile.read_text().splitlines()[0])
            pages=json.load(urllib.request.urlopen(f'http://127.0.0.1:{port}/json/list'))
            client=DevTools(next(p['webSocketDebuggerUrl'] for p in pages if p['type']=='page'))
            client.call('Emulation.setDeviceMetricsOverride',dict(width=1400,height=1100,deviceScaleFactor=scale,mobile=False))
            client.call('Page.navigate',{'url':url})
            expression="new Promise(resolve=>{const t=setInterval(()=>{const e=document.getElementById('terrain-result');if(e?.dataset.status){clearInterval(t);resolve({status:e.dataset.status,text:e.textContent});}},100);setTimeout(()=>{clearInterval(t);resolve({status:'timeout'});},60000);})"
            result=client.call('Runtime.evaluate',dict(expression=expression,awaitPromise=True,returnByValue=True))['result'].get('value',{})
            if result.get('status')=='passed':
                setup=r'''(async()=>{
                  const f=document.getElementById('terrain-editor'),w=f.contentWindow,d=f.contentDocument;
                  const source=d.getElementById('source');
                  source.value='#wotlk\n#ac335\n#group RXPGuides Custom Guides\n#name Map drag test\nstep\n  .goto Durotar,43.33,68.61,60,0 >>Keep this text << Orc\n';
                  source.dispatchEvent(new w.Event('input',{bubbles:true}));await new Promise(r=>setTimeout(r,500));
                  const list=d.getElementById('map-waypoints');list.value='1';list.dispatchEvent(new w.Event('change'));
                  await new Promise(r=>setTimeout(r,200));d.getElementById('terrain').scrollIntoView({block:'center'});
                  const c=d.getElementById('terrain').getBoundingClientRect(),b=f.getBoundingClientRect();
                  return {x:b.left+f.clientLeft+c.left+c.width/2,y:b.top+f.clientTop+c.top+c.height/2,before:source.value};
                })()'''
                point=client.call('Runtime.evaluate',dict(expression=setup,awaitPromise=True,returnByValue=True))['result']['value']
                def mouse(kind,x,y,button='left',buttons=1):
                    client.call('Input.dispatchMouseEvent',dict(type=kind,x=x,y=y,button=button,buttons=buttons,clickCount=1))
                x,y=point['x'],point['y']
                mouse('mouseMoved',x,y,'none',0);mouse('mousePressed',x,y);mouse('mouseMoved',x+25,y+18);mouse('mouseReleased',x+25,y+18,buttons=0)
                def evaluate(code):
                    response=client.call('Runtime.evaluate',dict(expression=code,awaitPromise=True,returnByValue=True))
                    if 'exceptionDetails' in response:raise RuntimeError('Browser interaction script failed')
                    return response['result'].get('value')
                source="document.getElementById('terrain-editor').contentDocument.getElementById('source').value"
                changed=evaluate(source)
                if changed==point['before'] or ',60,0 >>Keep this text << Orc' not in changed:raise RuntimeError('Drag did not perform a span-preserving edit')
                evaluate("document.getElementById('terrain-editor').contentDocument.getElementById('undo').click()")
                if evaluate(source)!=point['before']:raise RuntimeError('Drag was not one undoable edit')
                mouse('mousePressed',x,y);mouse('mouseMoved',x+40,y+15)
                client.call('Input.dispatchKeyEvent',dict(type='keyDown',key='Escape',code='Escape',windowsVirtualKeyCode=27));client.call('Input.dispatchKeyEvent',dict(type='keyUp',key='Escape',code='Escape',windowsVirtualKeyCode=27))
                mouse('mouseReleased',x+40,y+15,buttons=0)
                if evaluate(source)!=point['before']:raise RuntimeError('Cancelled drag changed source')
                narrow=evaluate("(async()=>{const f=document.getElementById('terrain-editor');f.width='375';await new Promise(r=>setTimeout(r,200));const d=f.contentDocument,c=d.getElementById('terrain').getBoundingClientRect();return d.documentElement.scrollWidth<=d.documentElement.clientWidth+2&&Math.abs(c.width-c.height)<=1;})()")
                if not narrow:raise RuntimeError('Narrow map overflows or is not square')
                evaluate("document.getElementById('terrain-editor').width='1280'")
                result['interactions']='Native pointer drag, single Undo, Escape cancellation, square wide/narrow layout and bounded smooth zoom passed'
            screenshot=client.call('Page.captureScreenshot',dict(format='png'))['data']
            (output/'terrain.png').write_bytes(base64.b64decode(screenshot))
            (output/'result.json').write_text(json.dumps(result),encoding='utf-8');print(result)
            if result.get('status')!='passed':raise RuntimeError('Terrain browser checks failed')
            success=True
        finally:
            if client:client.socket.close()
            process.terminate();process.wait(timeout=15)
    finally:
        httpd.shutdown();httpd.server_close();thread.join()
        if success:
            if profile.resolve().parent!=output or profile.is_symlink() or profile.is_junction():
                raise RuntimeError('Refusing unsafe test-profile cleanup')
            shutil.rmtree(profile)

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--browser',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--zone');parser.add_argument('--prefix',default='/')
    parser.add_argument('--scale',type=int,choices=[1,2,3],default=1)
    parser.add_argument('--site-root',type=Path)
    args=parser.parse_args();run(args.browser,args.output,args.zone,args.prefix,args.scale,args.site_root)
