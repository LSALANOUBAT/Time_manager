"use strict";(self["webpackChunkfrontend"]=self["webpackChunkfrontend"]||[]).push([[241],{2335:function(t,n,e){e.d(n,{a:function(){return a},c:function(){return h},g:function(){return l},s:function(){return f}});var o=e(5518);
/*!
 * (C) Ionic http://ionicframework.com - MIT License
 */const r="ION-CONTENT",s="ion-content",c=".ion-content-scroll-host",i=`${s}, ${c}`,u=t=>t.tagName===r,l=async t=>u(t)?(await new Promise((n=>(0,o.c)(t,n))),t.getScrollElement()):t,a=t=>t.closest(i),f=(t,n)=>{if(u(t)){const e=t;return e.scrollToTop(n)}return Promise.resolve(t.scrollTo({top:0,left:0,behavior:n>0?"smooth":"auto"}))},h=(t,n,e,o)=>{if(u(t)){const r=t;return r.scrollByPoint(n,e,o)}return Promise.resolve(t.scrollBy({top:e,left:n,behavior:o>0?"smooth":"auto"}))}},9241:function(t,n,e){e.r(n),e.d(n,{startStatusTap:function(){return c}});var o=e(5808),r=e(2335),s=e(5518);
/*!
 * (C) Ionic http://ionicframework.com - MIT License
 */
const c=()=>{const t=window;t.addEventListener("statusTap",(()=>{(0,o.gv)((()=>{const n=t.innerWidth,e=t.innerHeight,c=document.elementFromPoint(n/2,e/2);if(!c)return;const i=(0,r.a)(c);i&&new Promise((t=>(0,s.c)(i,t))).then((()=>{(0,o.bN)((async()=>{i.style.setProperty("--overflow","hidden"),await(0,r.s)(i,300),i.style.removeProperty("--overflow")}))}))}))}))}}}]);
//# sourceMappingURL=241.c45dc50e.js.map