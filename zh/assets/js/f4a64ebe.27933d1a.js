"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[6508],{5830:(e,n,o)=>{o.r(n),o.d(n,{assets:()=>c,contentTitle:()=>r,default:()=>u,frontMatter:()=>l,metadata:()=>s,toc:()=>d});var t=o(5893),i=o(1151);const l={sidebar_position:5},r="Polylux",s={id:"integration/polylux",title:"Polylux",description:"\u501f\u52a9 Touying \u4e0e Polylux \u7684\u517c\u5bb9\u6027\uff0c\u4f60\u53ef\u4ee5\u8ba9 Polylux \u4e5f\u652f\u6301\u76f4\u63a5\u5bfc\u51fa\uff0c\u53ea\u9700\u8981\u5728\u4f60\u7684 Polylux \u6e90\u4ee3\u7801\u4e2d\u52a0\u5165\u4e0b\u9762\u7684\u4ee3\u7801\u5373\u53ef\u3002",source:"@site/i18n/zh/docusaurus-plugin-content-docs/version-0.3.x/integration/polylux.md",sourceDirName:"integration",slug:"/integration/polylux",permalink:"/touying/zh/docs/integration/polylux",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/versioned_docs/version-0.3.x/integration/polylux.md",tags:[],version:"0.3.x",sidebarPosition:5,frontMatter:{sidebar_position:5},sidebar:"tutorialSidebar",previous:{title:"Codly",permalink:"/touying/zh/docs/integration/codly"},next:{title:"Themes",permalink:"/touying/zh/docs/category/themes"}},c={},d=[];function p(e){const n={code:"code",h1:"h1",p:"p",pre:"pre",...(0,i.a)(),...e.components};return(0,t.jsxs)(t.Fragment,{children:[(0,t.jsx)(n.h1,{id:"polylux",children:"Polylux"}),"\n",(0,t.jsx)(n.p,{children:"\u501f\u52a9 Touying \u4e0e Polylux \u7684\u517c\u5bb9\u6027\uff0c\u4f60\u53ef\u4ee5\u8ba9 Polylux \u4e5f\u652f\u6301\u76f4\u63a5\u5bfc\u51fa\uff0c\u53ea\u9700\u8981\u5728\u4f60\u7684 Polylux \u6e90\u4ee3\u7801\u4e2d\u52a0\u5165\u4e0b\u9762\u7684\u4ee3\u7801\u5373\u53ef\u3002"}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{children:'#import "@preview/touying:0.3.1"\n\n#locate(loc => touying.pdfpc.pdfpc-file(loc))\n'})}),"\n",(0,t.jsxs)(n.p,{children:["\u5047\u8bbe\u4f60\u7684\u6587\u6863\u4e3a ",(0,t.jsx)(n.code,{children:"./example.typ"}),"\uff0c\u5219\u4f60\u53ef\u4ee5\u901a\u8fc7"]}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-sh",children:'typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc\n'})}),"\n",(0,t.jsxs)(n.p,{children:["\u76f4\u63a5\u5bfc\u51fa ",(0,t.jsx)(n.code,{children:".pdfpc"})," \u6587\u4ef6\uff0c\u800c\u4e0d\u9700\u8981\u4f7f\u7528\u989d\u5916\u7684 ",(0,t.jsx)(n.code,{children:"polylux2pdfpc"})," \u7a0b\u5e8f\u3002"]})]})}function u(e={}){const{wrapper:n}={...(0,i.a)(),...e.components};return n?(0,t.jsx)(n,{...e,children:(0,t.jsx)(p,{...e})}):p(e)}},1151:(e,n,o)=>{o.d(n,{Z:()=>s,a:()=>r});var t=o(7294);const i={},l=t.createContext(i);function r(e){const n=t.useContext(l);return t.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function s(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:r(e.components),t.createElement(l.Provider,{value:n},e.children)}}}]);