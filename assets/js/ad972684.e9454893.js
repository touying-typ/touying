"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[6403],{7378:(e,o,t)=>{t.r(o),t.d(o,{assets:()=>c,contentTitle:()=>r,default:()=>u,frontMatter:()=>l,metadata:()=>s,toc:()=>d});var n=t(5893),i=t(1151);const l={sidebar_position:6},r="Polylux",s={id:"integration/polylux",title:"Polylux",description:"With the compatibility between Touying and Polylux, you can make Polylux support direct export as well. Just add the following code to your Polylux source code:",source:"@site/versioned_docs/version-0.3.x/integration/polylux.md",sourceDirName:"integration",slug:"/integration/polylux",permalink:"/touying/docs/0.3.x/integration/polylux",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/versioned_docs/version-0.3.x/integration/polylux.md",tags:[],version:"0.3.x",sidebarPosition:6,frontMatter:{sidebar_position:6},sidebar:"tutorialSidebar",previous:{title:"Codly",permalink:"/touying/docs/0.3.x/integration/codly"},next:{title:"Themes",permalink:"/touying/docs/0.3.x/category/themes"}},c={},d=[];function a(e){const o={code:"code",h1:"h1",p:"p",pre:"pre",...(0,i.a)(),...e.components};return(0,n.jsxs)(n.Fragment,{children:[(0,n.jsx)(o.h1,{id:"polylux",children:"Polylux"}),"\n",(0,n.jsx)(o.p,{children:"With the compatibility between Touying and Polylux, you can make Polylux support direct export as well. Just add the following code to your Polylux source code:"}),"\n",(0,n.jsx)(o.pre,{children:(0,n.jsx)(o.code,{className:"language-typst",children:'#import "@preview/touying:0.3.1"\n\n#locate(loc => touying.pdfpc.pdfpc-file(loc))\n'})}),"\n",(0,n.jsxs)(o.p,{children:["Assuming your document is ",(0,n.jsx)(o.code,{children:"./example.typ"}),", you can then export the ",(0,n.jsx)(o.code,{children:".pdfpc"})," file directly using the following command:"]}),"\n",(0,n.jsx)(o.pre,{children:(0,n.jsx)(o.code,{className:"language-sh",children:'typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc\n'})}),"\n",(0,n.jsxs)(o.p,{children:["This eliminates the need for an additional ",(0,n.jsx)(o.code,{children:"polylux2pdfpc"})," program."]})]})}function u(e={}){const{wrapper:o}={...(0,i.a)(),...e.components};return o?(0,n.jsx)(o,{...e,children:(0,n.jsx)(a,{...e})}):a(e)}},1151:(e,o,t)=>{t.d(o,{Z:()=>s,a:()=>r});var n=t(7294);const i={},l=n.createContext(i);function r(e){const o=n.useContext(l);return n.useMemo((function(){return"function"==typeof e?e(o):{...o,...e}}),[o,e])}function s(e){let o;return o=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:r(e.components),n.createElement(l.Provider,{value:o},e.children)}}}]);