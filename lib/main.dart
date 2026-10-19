<!doctype html>
<html lang="ar" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="theme-color" content="#3659d9">
<title>مذكّرتي</title>
<style>
:root{--blue:#3659d9;--bg:#f4f6fb;--ink:#1d2433;--muted:#70798b;--card:#fff;--line:#e5e9f2}
*{box-sizing:border-box}body{margin:0;font-family:system-ui,-apple-system,"Segoe UI",Tahoma,sans-serif;background:var(--bg);color:var(--ink)}
header{background:linear-gradient(135deg,#3659d9,#6b7ff0);color:white;padding:25px 18px 30px;border-radius:0 0 26px 26px}
.top{max-width:760px;margin:auto}.brand{font-size:14px;opacity:.9}.title{font-size:30px;font-weight:800;margin:5px 0}.subtitle{opacity:.9;font-size:14px}
main{max-width:760px;margin:-13px auto 40px;padding:0 14px}.search{width:100%;border:0;border-radius:15px;padding:15px 16px;font-size:16px;box-shadow:0 5px 18px #24345b12;outline:none;background:white}
.actions{display:flex;gap:9px;margin:13px 0;flex-wrap:wrap}.btn{border:0;border-radius:12px;padding:12px 15px;font-size:14px;font-weight:700;cursor:pointer}.primary{background:var(--blue);color:#fff}.soft{background:#e9edff;color:var(--blue)}.count{color:var(--muted);font-size:13px;margin:16px 3px 10px}
.notes{display:grid;gap:12px}.note{background:var(--card);border:1px solid var(--line);border-radius:17px;padding:16px;box-shadow:0 4px 14px #24345b08}.note-head{display:flex;align-items:flex-start;gap:8px}.note h3{margin:0;font-size:18px;overflow-wrap:anywhere;flex:1}.note p{white-space:pre-wrap;overflow-wrap:anywhere;color:#525b6c;line-height:1.65;margin:10px 0}.date{font-size:12px;color:var(--muted)}.note-actions{display:flex;gap:7px;margin-top:12px}.small{padding:7px 10px;border-radius:9px;font-size:13px}.star{background:transparent;color:#e0a000;border:0;font-size:22px;cursor:pointer;padding:0 2px}.empty{text-align:center;padding:35px 15px;color:var(--muted);background:white;border-radius:17px;border:1px dashed #cfd6e5}.empty b{display:block;color:var(--ink);font-size:18px;margin-bottom:7px}
dialog{border:0;border-radius:22px;width:min(560px,calc(100% - 24px));padding:0;box-shadow:0 20px 80px #1115}dialog::backdrop{background:#12182a88}.modal{padding:20px}.modal h2{margin:0 0 16px}.field{display:block;width:100%;border:1px solid var(--line);border-radius:12px;padding:13px;font:inherit;margin:10px 0;outline-color:var(--blue)}textarea.field{min-height:170px;resize:vertical}.modal-foot{display:flex;gap:8px;margin-top:12px}.modal-foot button{flex:1}.danger{background:#fff0f0;color:#c33}.footer{text-align:center;color:#8790a0;font-size:12px;margin:22px 0}
@media(min-width:600px){.notes{grid-template-columns:repeat(2,minmax(0,1fr))}}
</style>
</head>
<body>
<header><div class="top"><div class="brand">📝 مساحة أفكارك</div><div class="title">مذكّرتي</div><div class="subtitle">كل أفكارك وملاحظاتك في مكان واحد</div></div></header>
<main>
<input id="search" class="search" placeholder="🔎 ابحث في مذكراتك..." aria-label="ابحث في المذكرات">
<div class="actions"><button class="btn primary" id="add">＋ مذكرة جديدة</button><button class="btn soft" id="all">كل المذكرات</button><button class="btn soft" id="favorites">⭐ المفضلة</button></div>
<div class="count" id="count">0 مذكرات</div>
<section class="notes" id="notes"></section>
<div class="footer">تُحفظ مذكراتك على هذا الجهاز في هذا المتصفح.</div>
</main>
<dialog id="editor"><form id="form" class="modal">
<h2 id="modalTitle">مذكرة جديدة</h2>
<input id="noteTitle" class="field" maxlength="120" placeholder="عنوان المذكرة" required>
<textarea id="noteBody" class="field" placeholder="اكتب ملاحظتك هنا..."></textarea>
<div class="modal-foot"><button class="btn primary" type="submit">حفظ المذكرة</button><button class="btn soft" type="button" id="cancel">إلغاء</button></div>
</form></dialog>
<script>
const STORE='my-notes-ar-v1';
let notes=[];try{notes=JSON.parse(localStorage.getItem(STORE)||'[]')}catch(e){notes=[]}
let editing=null, view='all';
const $=id=>document.getElementById(id);
const save=()=>localStorage.setItem(STORE,JSON.stringify(notes));
const esc=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
function render(){
 const q=$('search').value.trim().toLowerCase();
 const shown=notes.filter(n=>(view==='all'||n.favorite)&&(!q||(n.title+' '+n.body).toLowerCase().includes(q))).sort((a,b)=>b.updated-a.updated);
 $('count').textContent=`${shown.length} من ${notes.length} مذكرة`;
 if(!shown.length){$('notes').innerHTML='<div class="empty"><b>لا توجد مذكرات هنا بعد</b>اضغط «مذكرة جديدة» لكتابة أول ملاحظة لك.</div>';return}
 $('notes').innerHTML=shown.map(n=>`<article class="note"><div class="note-head"><h3>${esc(n.title||'بدون عنوان')}</h3><button class="star" title="تبديل المفضلة" data-star="${n.id}">${n.favorite?'★':'☆'}</button></div><p>${esc(n.body||'')}</p><div class="date">آخر تعديل: ${new Date(n.updated).toLocaleString('ar')}</div><div class="note-actions"><button class="btn soft small" data-edit="${n.id}">✏️ تعديل</button><button class="btn danger small" data-delete="${n.id}">🗑️ حذف</button></div></article>`).join('');
}
function openEditor(n=null){editing=n?.id??null;$('modalTitle').textContent=n?'تعديل المذكرة':'مذكرة جديدة';$('noteTitle').value=n?.title||'';$('noteBody').value=n?.body||'';$('editor').showModal();$('noteTitle').focus()}
$('add').onclick=()=>openEditor();$('cancel').onclick=()=>$('editor').close();$('search').oninput=render;
$('all').onclick=()=>{view='all';render()};$('favorites').onclick=()=>{view='favorites';render()};
$('form').onsubmit=e=>{e.preventDefault();const now=Date.now(),title=$('noteTitle').value.trim(),body=$('noteBody').value.trim();if(!title&&!body)return; if(editing!==null){const n=notes.find(x=>x.id===editing);if(n){n.title=title;n.body=body;n.updated=now}}else notes.push({id:now+'-'+Math.random().toString(16).slice(2),title,body,favorite:false,created:now,updated:now});save();$('editor').close();render()};
$('notes').onclick=e=>{const b=e.target.closest('button');if(!b)return;const id=b.dataset.edit||b.dataset.delete||b.dataset.star;if(!id)return;const n=notes.find(x=>x.id===id);if(!n)return;if(b.dataset.edit)openEditor(n);else if(b.dataset.star!==undefined){n.favorite=!n.favorite;save();render()}else if(b.dataset.delete!==undefined&&confirm('هل تريد حذف هذه المذكرة؟')){notes=notes.filter(x=>x.id!==id);save();render()}};
render();
</script>
</body></html>