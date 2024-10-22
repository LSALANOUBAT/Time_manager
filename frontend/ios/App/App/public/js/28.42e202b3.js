"use strict";(self["webpackChunkfrontend"]=self["webpackChunkfrontend"]||[]).push([[28],{2335:function(e,t,o){o.d(t,{a:function(){return c},c:function(){return v},g:function(){return d},s:function(){return u}});var n=o(5518);
/*!
 * (C) Ionic http://ionicframework.com - MIT License
 */const r="ION-CONTENT",i="ion-content",s=".ion-content-scroll-host",a=`${i}, ${s}`,l=e=>e.tagName===r,d=async e=>l(e)?(await new Promise((t=>(0,n.c)(e,t))),e.getScrollElement()):e,c=e=>e.closest(a),u=(e,t)=>{if(l(e)){const o=e;return o.scrollToTop(t)}return Promise.resolve(e.scrollTo({top:0,left:0,behavior:t>0?"smooth":"auto"}))},v=(e,t,o,n)=>{if(l(e)){const r=e;return r.scrollByPoint(t,o,n)}return Promise.resolve(e.scrollBy({top:o,left:t,behavior:n>0?"smooth":"auto"}))}},1028:function(e,t,o){o.r(t),o.d(t,{startInputShims:function(){return M}});var n=o(3164),r=o(2335),i=o(5518),s=o(5980);
/*!
 * (C) Ionic http://ionicframework.com - MIT License
 */
const a=new WeakMap,l=(e,t,o,n=0,r=!1)=>{a.has(e)!==o&&(o?c(e,t,n,r):u(e,t))},d=e=>e===e.getRootNode().activeElement,c=(e,t,o,n=!1)=>{const r=t.parentNode,i=t.cloneNode(!1);i.classList.add("cloned-input"),i.tabIndex=-1,n&&(i.disabled=!0),r.appendChild(i),a.set(e,i);const s=e.ownerDocument,l="rtl"===s.dir?9999:-9999;e.style.pointerEvents="none",t.style.transform=`translate3d(${l}px,${o}px,0) scale(0)`},u=(e,t)=>{const o=a.get(e);o&&(a.delete(e),o.remove()),e.style.pointerEvents="",t.style.transform=""},v=50,m=(e,t,o)=>{if(!o||!t)return()=>{};const n=o=>{d(t)&&l(e,t,o)},r=()=>l(e,t,!1),s=()=>n(!0),a=()=>n(!1);return(0,i.a)(o,"ionScrollStart",s),(0,i.a)(o,"ionScrollEnd",a),t.addEventListener("blur",r),()=>{(0,i.b)(o,"ionScrollStart",s),(0,i.b)(o,"ionScrollEnd",a),t.removeEventListener("blur",r)}},f="input, textarea, [no-blur], [contenteditable]",w=()=>{let e=!0,t=!1;const o=document,n=()=>{t=!0},r=()=>{e=!0},s=n=>{if(t)return void(t=!1);const r=o.activeElement;if(!r)return;if(r.matches(f))return;const i=n.target;i!==r&&(i.matches(f)||i.closest(f)||(e=!1,setTimeout((()=>{e||r.blur()}),50)))};return(0,i.a)(o,"ionScrollStart",n),o.addEventListener("focusin",r,!0),o.addEventListener("touchend",s,!1),()=>{(0,i.b)(o,"ionScrollStart",n,!0),o.removeEventListener("focusin",r,!0),o.removeEventListener("touchend",s,!1)}},h=.3,p=(e,t,o,n)=>{var r;const i=null!==(r=e.closest("ion-item,[ion-item]"))&&void 0!==r?r:e;return y(i.getBoundingClientRect(),t.getBoundingClientRect(),o,n)},y=(e,t,o,n)=>{const r=e.top,i=e.bottom,s=t.top,a=Math.min(t.bottom,n-o),l=s+15,d=a-v,c=d-i,u=l-r,m=Math.round(c<0?-c:u>0?-u:0),f=Math.min(m,r-s),w=Math.abs(f),p=w/h,y=Math.min(400,Math.max(150,p));return{scrollAmount:f,scrollDuration:y,scrollPadding:o,inputSafeY:4-(r-l)}},b="$ionPaddingTimer",E=(e,t,o)=>{const n=e[b];n&&clearTimeout(n),t>0?e.style.setProperty("--keyboard-offset",`${t}px`):e[b]=setTimeout((()=>{e.style.setProperty("--keyboard-offset","0px"),o&&o()}),120)},g=(e,t,o)=>{const n=()=>{t&&E(t,0,o)};e.addEventListener("focusout",n,{once:!0})};let S=0;const L="data-ionic-skip-scroll-assist",D=(e,t,o,r,i,a,l,d=!1)=>{const c=a&&(void 0===l||l.mode===s.a.None);let u=!1;const v=void 0!==n.w?n.w.innerHeight:0,m=n=>{!1!==u?T(e,t,o,r,n.detail.keyboardHeight,c,d,v,!1):u=!0},f=()=>{u=!1,null===n.w||void 0===n.w||n.w.removeEventListener("ionKeyboardDidShow",m),e.removeEventListener("focusout",f)},w=async()=>{t.hasAttribute(L)?t.removeAttribute(L):(T(e,t,o,r,i,c,d,v),null===n.w||void 0===n.w||n.w.addEventListener("ionKeyboardDidShow",m),e.addEventListener("focusout",f))};return e.addEventListener("focusin",w),()=>{e.removeEventListener("focusin",w),null===n.w||void 0===n.w||n.w.removeEventListener("ionKeyboardDidShow",m),e.removeEventListener("focusout",f)}},k=e=>{document.activeElement!==e&&(e.setAttribute(L,"true"),e.focus())},T=async(e,t,o,n,s,a,d=!1,c=0,u=!0)=>{if(!o&&!n)return;const m=p(e,o||n,s,c);if(o&&Math.abs(m.scrollAmount)<4)return k(t),void(a&&null!==o&&(E(o,S),g(t,o,(()=>S=0))));if(l(e,t,!0,m.inputSafeY,d),k(t),(0,i.r)((()=>e.click())),a&&o&&(S=m.scrollPadding,E(o,S)),"undefined"!==typeof window){let n;const i=async()=>{void 0!==n&&clearTimeout(n),window.removeEventListener("ionKeyboardDidShow",s),window.removeEventListener("ionKeyboardDidShow",i),o&&await(0,r.c)(o,0,m.scrollAmount,m.scrollDuration),l(e,t,!1,m.inputSafeY),k(t),a&&g(t,o,(()=>S=0))},s=()=>{window.removeEventListener("ionKeyboardDidShow",s),window.addEventListener("ionKeyboardDidShow",i)};if(o){const e=await(0,r.g)(o),a=e.scrollHeight-e.clientHeight;if(u&&m.scrollAmount>a-e.scrollTop)return"password"===t.type?(m.scrollAmount+=v,window.addEventListener("ionKeyboardDidShow",s)):window.addEventListener("ionKeyboardDidShow",i),void(n=setTimeout(i,1e3))}i()}},A=!0,M=async(e,t)=>{if(void 0===n.d)return;const o="ios"===t,a="android"===t,l=e.getNumber("keyboardHeight",290),d=e.getBoolean("scrollAssist",!0),c=e.getBoolean("hideCaretOnScroll",o),u=e.getBoolean("inputBlurring",!1),v=e.getBoolean("scrollPadding",!0),f=Array.from(n.d.querySelectorAll("ion-input, ion-textarea")),h=new WeakMap,p=new WeakMap,y=await s.K.getResizeMode(),b=async e=>{await new Promise((t=>(0,i.c)(e,t)));const t=e.shadowRoot||e,o=t.querySelector("input")||t.querySelector("textarea"),n=(0,r.a)(e),s=n?null:e.closest("ion-footer");if(!o)return;if(n&&c&&!h.has(e)){const t=m(e,o,n);h.set(e,t)}const u="date"===o.type||"datetime-local"===o.type;if(!u&&(n||s)&&d&&!p.has(e)){const t=D(e,o,n,s,l,v,y,a);p.set(e,t)}},E=e=>{if(c){const t=h.get(e);t&&t(),h.delete(e)}if(d){const t=p.get(e);t&&t(),p.delete(e)}};u&&A&&w();for(const n of f)b(n);n.d.addEventListener("ionInputDidLoad",(e=>{b(e.detail)})),n.d.addEventListener("ionInputDidUnload",(e=>{E(e.detail)}))}}}]);
//# sourceMappingURL=28.42e202b3.js.map