"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[8993],{1660:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>o,contentTitle:()=>c,default:()=>a,frontMatter:()=>s,metadata:()=>i,toc:()=>r});var d=t(5893),p=t(1151);const s={sidebar_position:1},c="pdfpc",i={id:"external/pdfpc",title:"pdfpc",description:'pdfpc \u662f\u4e00\u4e2a "\u5bf9 PDF \u6587\u6863\u5177\u6709\u591a\u663e\u793a\u5668\u652f\u6301\u7684\u6f14\u793a\u8005\u63a7\u5236\u53f0"\u3002\u8fd9\u610f\u5473\u7740\uff0c\u60a8\u53ef\u4ee5\u4f7f\u7528\u5b83\u4ee5 PDF \u9875\u9762\u7684\u5f62\u5f0f\u663e\u793a\u5e7b\u706f\u7247\uff0c\u5e76\u4e14\u8fd8\u5177\u6709\u4e00\u4e9b\u5df2\u77e5\u7684\u51fa\u8272\u529f\u80fd\uff0c\u5c31\u50cf PowerPoint \u4e00\u6837\u3002',source:"@site/i18n/zh/docusaurus-plugin-content-docs/current/external/pdfpc.md",sourceDirName:"external",slug:"/external/pdfpc",permalink:"/touying/zh/docs/next/external/pdfpc",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/docs/external/pdfpc.md",tags:[],version:"current",sidebarPosition:1,frontMatter:{sidebar_position:1},sidebar:"tutorialSidebar",previous:{title:"External Tools",permalink:"/touying/zh/docs/next/category/external-tools"},next:{title:"Typst Preview",permalink:"/touying/zh/docs/next/external/typst-preview"}},o={},r=[{value:"\u52a0\u5165 Metadata",id:"\u52a0\u5165-metadata",level:2},{value:"pdfpc \u914d\u7f6e",id:"pdfpc-\u914d\u7f6e",level:2},{value:"\u8f93\u51fa .pdfpc \u6587\u4ef6",id:"\u8f93\u51fa-pdfpc-\u6587\u4ef6",level:2}];function l(e){const n={a:"a",code:"code",h1:"h1",h2:"h2",p:"p",pre:"pre",...(0,p.a)(),...e.components};return(0,d.jsxs)(d.Fragment,{children:[(0,d.jsx)(n.h1,{id:"pdfpc",children:"pdfpc"}),"\n",(0,d.jsxs)(n.p,{children:[(0,d.jsx)(n.a,{href:"https://pdfpc.github.io/",children:"pdfpc"}),' \u662f\u4e00\u4e2a "\u5bf9 PDF \u6587\u6863\u5177\u6709\u591a\u663e\u793a\u5668\u652f\u6301\u7684\u6f14\u793a\u8005\u63a7\u5236\u53f0"\u3002\u8fd9\u610f\u5473\u7740\uff0c\u60a8\u53ef\u4ee5\u4f7f\u7528\u5b83\u4ee5 PDF \u9875\u9762\u7684\u5f62\u5f0f\u663e\u793a\u5e7b\u706f\u7247\uff0c\u5e76\u4e14\u8fd8\u5177\u6709\u4e00\u4e9b\u5df2\u77e5\u7684\u51fa\u8272\u529f\u80fd\uff0c\u5c31\u50cf PowerPoint \u4e00\u6837\u3002']}),"\n",(0,d.jsxs)(n.p,{children:["pdfpc \u6709\u4e00\u4e2a JSON \u683c\u5f0f\u7684 ",(0,d.jsx)(n.code,{children:".pdfpc"})," \u6587\u4ef6\uff0c\u5b83\u53ef\u4ee5\u4e3a PDF slides \u63d0\u4f9b\u66f4\u591a\u7684\u4fe1\u606f\u3002\u867d\u7136\u60a8\u53ef\u4ee5\u624b\u52a8\u7f16\u5199\u5b83\uff0c\u4f46\u4f60\u4e5f\u53ef\u4ee5\u901a\u8fc7 Touying \u6765\u7ba1\u7406\u3002"]}),"\n",(0,d.jsx)(n.h2,{id:"\u52a0\u5165-metadata",children:"\u52a0\u5165 Metadata"}),"\n",(0,d.jsxs)(n.p,{children:["Touying \u4e0e ",(0,d.jsx)(n.a,{href:"https://polylux.dev/book/external/pdfpc.html",children:"Polylux"})," \u4fdd\u6301\u4e00\u81f4\uff0c\u4ee5\u907f\u514d API \u4e4b\u95f4\u7684\u51b2\u7a81\u3002"]}),"\n",(0,d.jsxs)(n.p,{children:["\u4f8b\u5982\uff0c\u4f60\u53ef\u4ee5\u901a\u8fc7 ",(0,d.jsx)(n.code,{children:'#pdfpc.speaker-note("This is a note that only the speaker will see.")'})," \u52a0\u5165 notes\u3002"]}),"\n",(0,d.jsx)(n.h2,{id:"pdfpc-\u914d\u7f6e",children:"pdfpc \u914d\u7f6e"}),"\n",(0,d.jsx)(n.p,{children:"\u4e3a\u4e86\u52a0\u5165 pdfpc \u914d\u7f6e\uff0c\u4f60\u53ef\u4ee5\u4f7f\u7528"}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-typst",children:'#let s = (s.methods.append-preamble)(self: s, pdfpc.config(\n  duration-minutes: 30,\n  start-time: datetime(hour: 14, minute: 10, second: 0),\n  end-time: datetime(hour: 14, minute: 40, second: 0),\n  last-minutes: 5,\n  note-font-size: 12,\n  disable-markdown: false,\n  default-transition: (\n    type: "push",\n    duration-seconds: 2,\n    angle: ltr,\n    alignment: "vertical",\n    direction: "inward",\n  ),\n))\n'})}),"\n",(0,d.jsxs)(n.p,{children:["\u52a0\u5165\u5bf9\u5e94\u7684\u914d\u7f6e\uff0c\u5177\u4f53\u914d\u7f6e\u65b9\u6cd5\u53ef\u4ee5\u53c2\u8003 ",(0,d.jsx)(n.a,{href:"https://polylux.dev/book/external/pdfpc.html",children:"Polylux"}),"\u3002"]}),"\n",(0,d.jsx)(n.h2,{id:"\u8f93\u51fa-pdfpc-\u6587\u4ef6",children:"\u8f93\u51fa .pdfpc \u6587\u4ef6"}),"\n",(0,d.jsxs)(n.p,{children:["\u5047\u8bbe\u4f60\u7684\u6587\u6863\u4e3a ",(0,d.jsx)(n.code,{children:"./example.typ"}),"\uff0c\u5219\u4f60\u53ef\u4ee5\u901a\u8fc7"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-sh",children:'typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc\n'})}),"\n",(0,d.jsxs)(n.p,{children:["\u76f4\u63a5\u5bfc\u51fa ",(0,d.jsx)(n.code,{children:".pdfpc"})," \u6587\u4ef6\u3002"]}),"\n",(0,d.jsx)(n.p,{children:"\u501f\u52a9 Touying \u4e0e Polylux \u7684\u517c\u5bb9\u6027\uff0c\u4f60\u53ef\u4ee5\u8ba9 Polylux \u4e5f\u652f\u6301\u76f4\u63a5\u5bfc\u51fa\uff0c\u53ea\u9700\u8981\u52a0\u5165\u4e0b\u9762\u7684\u4ee3\u7801\u5373\u53ef\u3002"}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{children:'#import "@preview/touying:0.3.2"\n\n#locate(loc => touying.pdfpc.pdfpc-file(loc))\n'})})]})}function a(e={}){const{wrapper:n}={...(0,p.a)(),...e.components};return n?(0,d.jsx)(n,{...e,children:(0,d.jsx)(l,{...e})}):l(e)}},1151:(e,n,t)=>{t.d(n,{Z:()=>i,a:()=>c});var d=t(7294);const p={},s=d.createContext(p);function c(e){const n=d.useContext(s);return d.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function i(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(p):e.components||p:c(e.components),d.createElement(s.Provider,{value:n},e.children)}}}]);