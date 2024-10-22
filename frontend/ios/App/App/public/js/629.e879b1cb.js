"use strict";(self["webpackChunkfrontend"]=self["webpackChunkfrontend"]||[]).push([[629],{6629:function(e,t,s){s.r(t),s.d(t,{scopeCss:function(){return X}});s(4114);var r=e=>e.replace(/[.*+?^${}()|[\]\\]/g,"\\$&"),n=e=>{const t=[];let s=0;e=e.replace(/(\[[^\]]*\])/g,((e,r)=>{const n=`__ph-${s}__`;return t.push(r),s++,n}));const r=e.replace(/(:nth-[-\w]+)(\([^)]+\))/g,((e,r,n)=>{const c=`__ph-${s}__`;return t.push(n),s++,r+c})),n={content:r,placeholders:t};return n},c=(e,t)=>t.replace(/__ph-(\d+)__/g,((t,s)=>e[+s])),o="-shadowcsshost",l="-shadowcssslotted",p="-shadowcsscontext",i=")(?:\\(((?:\\([^)(]*\\)|[^)(]*)+?)\\))?([^,{]*)",a=new RegExp("("+o+i,"gim"),u=new RegExp("("+p+i,"gim"),h=new RegExp("("+l+i,"gim"),g=o+"-no-combinator",d=/-shadowcsshost-no-combinator([^\s]*)/,m=[/::shadow/g,/::content/g],$="([>\\s~+[.,{:][\\s\\S]*)?$",f=/-shadowcsshost/gim,x=e=>new RegExp(`((?<!(^@supports(.*)))|(?<={.*))(${e}\\b)`,"gim"),w=x("::slotted"),S=x(":host"),b=x(":host-context"),_=/\/\*\s*[\s\S]*?\*\//g,k=e=>e.replace(_,""),E=/\/\*\s*#\s*source(Mapping)?URL=[\s\S]+?\*\//g,O=e=>e.match(E)||[],R=/(\s*)([^;\{\}]+?)(\s*)((?:{%BLOCK%}?\s*;?)|(?:\s*;))/g,j=/([{}])/g,C=/(^.*?[^\\])??((:+)(.*)|$)/,W="{",T="}",L="%BLOCK%",B=(e,t)=>{const s=I(e);let r=0;return s.escapedString.replace(R,((...e)=>{const n=e[2];let c="",o=e[4],l="";o&&o.startsWith("{"+L)&&(c=s.blocks[r++],o=o.substring(L.length+1),l="{");const p={selector:n,content:c},i=t(p);return`${e[1]}${i.selector}${e[3]}${l}${i.content}${o}`}))},I=e=>{const t=e.split(j),s=[],r=[];let n=0,c=[];for(let l=0;l<t.length;l++){const e=t[l];e===T&&n--,n>0?c.push(e):(c.length>0&&(r.push(c.join("")),s.push(L),c=[]),s.push(e)),e===W&&n++}c.length>0&&(r.push(c.join("")),s.push(L));const o={escapedString:s.join(""),blocks:r};return o},K=e=>(e=e.replace(b,`$1${p}`).replace(S,`$1${o}`).replace(w,`$1${l}`),e),v=(e,t,s)=>e.replace(t,((...e)=>{if(e[2]){const t=e[2].split(","),r=[];for(let n=0;n<t.length;n++){const c=t[n].trim();if(!c)break;r.push(s(g,c,e[3]))}return r.join(",")}return g+e[3]})),M=(e,t,s)=>e+t.replace(o,"")+s,U=e=>v(e,a,M),q=(e,t,s)=>t.indexOf(o)>-1?M(e,t,s):e+t+s+", "+t+" "+e+s,y=(e,t)=>{const s="."+t+" > ",r=[];return e=e.replace(h,((...e)=>{if(e[2]){const t=e[2].trim(),n=e[3],c=s+t+n;let o="";for(let s=e[4]-1;s>=0;s--){const t=e[5][s];if("}"===t||","===t)break;o=t+o}const l=(o+c).trim(),p=`${o.trimEnd()}${c.trim()}`.trim();if(l!==p){const e=`${p}, ${l}`;r.push({orgSelector:l,updatedSelector:e})}return c}return g+e[3]})),{selectors:r,cssText:e}},z=e=>v(e,u,q),A=e=>m.reduce(((e,t)=>e.replace(t," ")),e),D=e=>{const t=/\[/g,s=/\]/g;return e=e.replace(t,"\\[").replace(s,"\\]"),new RegExp("^("+e+")"+$,"m")},F=(e,t)=>{const s=D(t);return!s.test(e)},G=(e,t)=>e.replace(C,((e,s="",r,n="",c="")=>s+t+n+c)),H=(e,t,s)=>{if(f.lastIndex=0,f.test(e)){const t=`.${s}`;return e.replace(d,((e,s)=>G(s,t))).replace(f,t+" ")}return t+" "+e},J=(e,t,s)=>{const r=/\[is=([^\]]*)\]/g;t=t.replace(r,((e,...t)=>t[0]));const o="."+t,l=e=>{let r=e.trim();if(!r)return"";if(e.indexOf(g)>-1)r=H(e,t,s);else{const t=e.replace(f,"");t.length>0&&(r=G(t,o))}return r},p=n(e);e=p.content;let i,a="",u=0;const h=/( |>|\+|~(?!=))\s*/g,d=e.indexOf(g)>-1;let m=!d;while(null!==(i=h.exec(e))){const t=i[1],s=e.slice(u,i.index).trim();m=m||s.indexOf(g)>-1;const r=m?l(s):s;a+=`${r} ${t} `,u=h.lastIndex}const $=e.substring(u);return m=m||$.indexOf(g)>-1,a+=m?l($):$,c(p.placeholders,a)},N=(e,t,s,r)=>e.split(",").map((e=>r&&e.indexOf("."+r)>-1?e.trim():F(e,t)?J(e,t,s).trim():e.trim())).join(", "),P=(e,t,s,r)=>B(e,(e=>{let n=e.selector,c=e.content;"@"!==e.selector[0]?n=N(e.selector,t,s,r):(e.selector.startsWith("@media")||e.selector.startsWith("@supports")||e.selector.startsWith("@page")||e.selector.startsWith("@document"))&&(c=P(e.content,t,s,r));const o={selector:n.replace(/\s{2,}/g," ").trim(),content:c};return o})),Q=(e,t,s,r)=>{e=K(e),e=U(e),e=z(e);const n=y(e,r);return e=n.cssText,e=A(e),t&&(e=P(e,t,s,r)),e=V(e,s),e=e.replace(/>\s*\*\s+([^{, ]+)/gm," $1 "),{cssText:e.trim(),slottedSelectors:n.selectors.map((e=>({orgSelector:V(e.orgSelector,s),updatedSelector:V(e.updatedSelector,s)})))}},V=(e,t)=>e.replace(/-shadowcsshost-no-combinator/g,`.${t}`),X=(e,t)=>{const s=t+"-h",n=t+"-s",c=O(e);e=k(e);const o=Q(e,t,s,n);return e=[o.cssText,...c].join("\n"),o.slottedSelectors.forEach((t=>{const s=new RegExp(r(t.orgSelector),"g");e=e.replace(s,t.updatedSelector)})),e}}}]);
//# sourceMappingURL=629.e879b1cb.js.map