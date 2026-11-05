export async function workspaceTests(test,assert,equal,sleep,w,d,input,basic){
  const $=id=>d.getElementById(id),change=(id,value)=>{$(id).value=value;$(id).dispatchEvent(new w.Event('change',{bubbles:true}));};
  await test('Workspace views preserve control identities, source, selection and pending drafts',async()=>{
    $('workspace-tabs-write').click();input('source',basic);await sleep(400);
    const ids=['source','instruction-form','display-text','steps','terrain','interior-canvas'],original=ids.map($),before=$('source').value;
    $('new-line').click();input('display-text','Unfinished instruction');await sleep(0);
    for(const view of ['map','source','write']){$('workspace-tabs-'+view).click();await sleep(80);}
    equal($('source').value,before);equal($('display-text').value,'Unfinished instruction');assert(!$('append-line').hidden);
    assert($('preview').textContent.includes('Unfinished instruction'));
    assert(ids.every((id,i)=>$(id)===original[i]));equal($('steps').value,'0');
    $('append-line').click();assert($('source').value.includes('Unfinished instruction'));
    $('workspace-tabs-source').click();$('workspace-tabs-write').click();$('undo').click();equal($('source').value,before);
  });
  await test('Filtered steps retain canonical indices, active selection and live form updates',async()=>{
    input('source',basic);await sleep(400);input('step-search','.turnin');
    equal([...$('steps').options].map(o=>o.value),['0','2']);assert($('step-search-status').textContent.includes('selected step retained'));
    change('steps','2');equal($('action').value,'turnin');assert($('selection-context').textContent.includes('step 3'));
    input('arg-0','4642');await sleep(0);assert($('source').value.includes('.turnin 4642'));assert($('steps').selectedOptions[0].textContent.includes('4642'));
    $('undo').click();equal($('source').value,basic);input('step-search','');equal($('steps').options.length,3);
  });
  await test('Problem links select the correct source span without changing content',async()=>{
    const broken=basic.replace('43.33','140');input('source',broken);await sleep(400);$('validate').click();
    assert($('problems-panel').open);assert($('problems-summary').textContent.includes('1 errors'));
    const link=[...$('diagnostics').querySelectorAll('button')].find(b=>b.textContent.includes('Coordinates must'));
    assert(link);link.click();equal($('source').value,broken);assert(!$('source-page').hidden);
    const area=$('source');assert(area.value.slice(area.selectionStart,area.selectionEnd).includes('Durotar,140,68.61'));
    assert($('instruction-errors').textContent.includes('Coordinates must'));equal($('steps').value,'0');
    equal($('arg-1').getAttribute('aria-invalid'),'true');assert(!$('arg-error-1').hidden);
    input('source',basic);await sleep(400);$('problems-panel').open=false;
    assert(!$('arg-1').hasAttribute('aria-invalid'));assert($('arg-error-1').hidden);
    link.click();equal($('source').value,basic);assert($('status').textContent.includes('Source changed'));
  });
  await test('Problem links account for surrounding Lua, Unicode and CRLF lines',async()=>{
    const broken=basic.replace('43.33','140'),wrapped='-- Café\r\nRXPGuides.RegisterGuide([[\r\n'+broken.replace(/\r?\n/g,'\r\n')+']])\r\n-- untouched\r\n';
    input('source',wrapped);await sleep(400);const before=$('source').value;
    const link=[...$('diagnostics').querySelectorAll('button')].find(b=>b.textContent.includes('Coordinates must'));
    assert(link);link.click();equal($('source').value,before);
    const source=$('source');assert(source.value.slice(source.selectionStart,source.selectionEnd).includes('Durotar,140,68.61'));
    input('source',basic);await sleep(400);
  });
  await test('Keyboard tabs, inspector visibility and source caret remain stable',async()=>{
    const source=$('source');source.focus();source.setSelectionRange(12,19);source.scrollTop=10;
    $('workspace-tabs-write').click();$('workspace-tabs-source').click();equal(source.selectionStart,12);equal(source.selectionEnd,19);
    const tab=$('workspace-tabs-source');tab.focus();tab.dispatchEvent(new w.KeyboardEvent('keydown',{key:'Home',bubbles:true,cancelable:true}));
    equal($('workspace-tabs-write').getAttribute('aria-selected'),'true');assert(!$('write-page').hidden);assert($('source-page').hidden);
    $('inspector-tabs-lookup').click();assert(!$('lookup-page').hidden);assert($('details-page').hidden);
    $('inspector-tabs-details').click();assert(!$('details-page').hidden);assert($('lookup-page').hidden);
    assert([...d.querySelectorAll('[role="tablist"]')].every(bar=>bar.querySelectorAll('[aria-selected="true"]').length===1));
  });
  await test('File and Export are separate, Escape closes menus and narrow outline is explicit',async()=>{
    const before=$('source').value;$('file-menu').open=true;await sleep(30);$('export-menu').open=true;await sleep(30);
    assert(!$('file-menu').open&&$('export-menu').open);assert($('export-menu').contains($('raw'))&&!$('toc'));
    assert($('file-menu').contains($('save'))&&!$('file-menu').contains($('raw')));
    d.dispatchEvent(new w.KeyboardEvent('keydown',{key:'Escape',bubbles:true,cancelable:true}));assert(!$('export-menu').open);
    $('outline-toggle').click();equal($('outline-toggle').getAttribute('aria-expanded'),'true');assert(w.getComputedStyle($('guide-outline')).display!=='none');
    $('outline-toggle').click();equal($('outline-toggle').getAttribute('aria-expanded'),'false');equal($('source').value,before);
    assert(d.documentElement.scrollWidth<=d.documentElement.clientWidth+2,'Workspace overflows narrow viewport');
  });
}
