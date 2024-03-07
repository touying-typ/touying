"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[3732],{1124:(e,t,o)=>{o.r(t),o.d(t,{assets:()=>s,contentTitle:()=>r,default:()=>u,frontMatter:()=>l,metadata:()=>c,toc:()=>d});var n=o(5893),i=o(1151);const l={sidebar_position:5},r="Polylux",c={id:"integration/polylux",title:"Polylux",description:"With the compatibility between Touying and Polylux, you can make Polylux support direct export as well. Just add the following code to your Polylux source code:",source:"@site/docs/integration/polylux.md",sourceDirName:"integration",slug:"/integration/polylux",permalink:"/touying/docs/next/integration/polylux",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/docs/integration/polylux.md",tags:[],version:"current",sidebarPosition:5,frontMatter:{sidebar_position:5},sidebar:"tutorialSidebar",previous:{title:"Codly",permalink:"/touying/docs/next/integration/codly"},next:{title:"Themes",permalink:"/touying/docs/next/category/themes"}},s={},d=[];function a(e){const t={code:"code",h1:"h1",p:"p",pre:"pre",...(0,i.a)(),...e.components};return(0,n.jsxs)(n.Fragment,{children:[(0,n.jsx)(t.h1,{id:"polylux",children:"Polylux"}),"\n",(0,n.jsx)(t.p,{children:"With the compatibility between Touying and Polylux, you can make Polylux support direct export as well. Just add the following code to your Polylux source code:"}),"\n",(0,n.jsx)(t.pre,{children:(0,n.jsx)(t.code,{className:"language-typst",children:'#import "@preview/touying:0.3.1"\n\n#locate(loc => touying.pdfpc.pdfpc-file(loc))\n'})}),"\n",(0,n.jsxs)(t.p,{children:["Assuming your document is ",(0,n.jsx)(t.code,{children:"./example.typ"}),", you can then export the ",(0,n.jsx)(t.code,{children:".pdfpc"})," file directly using the following command:"]}),"\n",(0,n.jsx)(t.pre,{children:(0,n.jsx)(t.code,{className:"language-sh",children:'typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc\n'})}),"\n",(0,n.jsxs)(t.p,{children:["This eliminates the need for an additional ",(0,n.jsx)(t.code,{children:"polylux2pdfpc"})," program."]})]})}function u(e={}){const{wrapper:t}={...(0,i.a)(),...e.components};return t?(0,n.jsx)(t,{...e,children:(0,n.jsx)(a,{...e})}):a(e)}},1151:(e,t,o)=>{o.d(t,{Z:()=>c,a:()=>r});var n=o(7294);const i={},l=n.createContext(i);function r(e){const t=n.useContext(l);return n.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function c(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:r(e.components),n.createElement(l.Provider,{value:t},e.children)}}}]);