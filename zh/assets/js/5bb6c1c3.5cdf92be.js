"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[3563],{998:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>d,contentTitle:()=>l,default:()=>a,frontMatter:()=>o,metadata:()=>c,toc:()=>r});var t=s(5893),i=s(1151);const o={sidebar_position:3},l="\u8282\u4e0e\u5c0f\u8282",c={id:"sections",title:"\u8282\u4e0e\u5c0f\u8282",description:"\u7ed3\u6784",source:"@site/i18n/zh/docusaurus-plugin-content-docs/current/sections.md",sourceDirName:".",slug:"/sections",permalink:"/touying/zh/docs/next/sections",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/docs/sections.md",tags:[],version:"current",sidebarPosition:3,frontMatter:{sidebar_position:3},sidebar:"tutorialSidebar",previous:{title:"\u5f00\u59cb",permalink:"/touying/zh/docs/next/start"},next:{title:"\u4ee3\u7801\u98ce\u683c",permalink:"/touying/zh/docs/next/code-styles"}},d={},r=[{value:"\u7ed3\u6784",id:"\u7ed3\u6784",level:2},{value:"\u76ee\u5f55",id:"\u76ee\u5f55",level:2}];function u(e){const n={code:"code",h1:"h1",h2:"h2",img:"img",p:"p",pre:"pre",...(0,i.a)(),...e.components};return(0,t.jsxs)(t.Fragment,{children:[(0,t.jsx)(n.h1,{id:"\u8282\u4e0e\u5c0f\u8282",children:"\u8282\u4e0e\u5c0f\u8282"}),"\n",(0,t.jsx)(n.h2,{id:"\u7ed3\u6784",children:"\u7ed3\u6784"}),"\n",(0,t.jsx)(n.p,{children:"\u4e0e Beamer \u76f8\u540c\uff0cTouying \u540c\u6837\u6709\u7740 section \u548c subsection \u7684\u6982\u5ff5\u3002"}),"\n",(0,t.jsx)(n.p,{children:"\u4e00\u822c\u800c\u8a00\uff0c1 \u7ea7\u30012 \u7ea7\u548c 3 \u7ea7\u6807\u9898\u5206\u522b\u7528\u6765\u5bf9\u5e94 section\u3001subsection \u548c title\uff0c\u4f8b\u5982 dewdrop \u4e3b\u9898\u3002"}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:'#import "@preview/touying:0.3.3": *\n\n#let s = themes.dewdrop.register()\n#let (init, slides) = utils.methods(s)\n#show: init\n\n#let (slide, empty-slide) = utils.slides(s)\n#show: slides\n\n= Section\n\n== Subsection\n\n=== Title\n\nHello, Touying!\n'})}),"\n",(0,t.jsx)(n.p,{children:(0,t.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/1574e74d-25c1-418f-a84f-b974f42edae5",alt:"image"})}),"\n",(0,t.jsx)(n.p,{children:"\u4f46\u662f\u5f88\u591a\u65f6\u5019\u6211\u4eec\u5e76\u4e0d\u9700\u8981 subsection\uff0c\u56e0\u6b64\u4e5f\u4f1a\u4f7f\u7528 1 \u7ea7\u548c 2 \u7ea7\u6807\u9898\u6765\u5206\u522b\u5bf9\u5e94 section \u548c title\uff0c\u4f8b\u5982 university \u4e3b\u9898\u3002"}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:'#import "@preview/touying:0.3.3": *\n\n#let s = themes.university.register()\n#let (init, slides) = utils.methods(s)\n#show: init\n\n#let (slide, empty-slide) = utils.slides(s)\n#show: slides\n\n= Section\n\n== Title\n\nHello, Touying!\n'})}),"\n",(0,t.jsx)(n.p,{children:(0,t.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/9dd77c98-9c08-4811-872e-092bbdebf394",alt:"image"})}),"\n",(0,t.jsxs)(n.p,{children:["\u5b9e\u9645\u4e0a\uff0c\u6211\u4eec\u53ef\u4ee5\u901a\u8fc7 ",(0,t.jsx)(n.code,{children:"slides"})," \u51fd\u6570\u7684 ",(0,t.jsx)(n.code,{children:"slide-level"})," \u53c2\u6570\u6765\u63a7\u5236\u8fd9\u91cc\u7684\u884c\u4e3a\u3002",(0,t.jsx)(n.code,{children:"slide-level"})," \u4ee3\u8868\u7740\u5d4c\u5957\u7ed3\u6784\u7684\u590d\u6742\u5ea6\uff0c\u4ece 0 \u5f00\u59cb\u8ba1\u7b97\u3002\u4f8b\u5982 ",(0,t.jsx)(n.code,{children:"#show: slides.with(slide-level: 2)"})," \u7b49\u4ef7\u4e8e ",(0,t.jsx)(n.code,{children:"section"}),"\uff0c",(0,t.jsx)(n.code,{children:"subsection"})," \u548c ",(0,t.jsx)(n.code,{children:"title"})," \u7ed3\u6784\uff1b\u800c ",(0,t.jsx)(n.code,{children:"#show: slides.with(slide-level: 1)"})," \u7b49\u4ef7\u4e8e ",(0,t.jsx)(n.code,{children:"section"})," \u548c ",(0,t.jsx)(n.code,{children:"title"})," \u7ed3\u6784\u3002"]}),"\n",(0,t.jsx)(n.h2,{id:"\u76ee\u5f55",children:"\u76ee\u5f55"}),"\n",(0,t.jsx)(n.p,{children:"\u5728 Touying \u4e2d\u663e\u793a\u76ee\u5f55\u5f88\u7b80\u5355\uff1a"}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:'#import "@preview/touying:0.3.3": *\n\n#let s = themes.simple.register()\n#let (init, slides, alert, touying-outline) = utils.methods(s)\n#show: init\n\n#let (slide, empty-slide) = utils.slides(s)\n#show: slides.with(slide-level: 2)\n\n= Section\n\n== Subsection\n\n=== Title\n\n==== Table of contents\n\n#touying-outline()\n'})}),"\n",(0,t.jsx)(n.p,{children:(0,t.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/3cc09550-d3cc-40c2-a315-22ca8173798f",alt:"image"})}),"\n",(0,t.jsxs)(n.p,{children:["\u5176\u4e2d ",(0,t.jsx)(n.code,{children:"touying-oultine()"})," \u7684\u5b9a\u4e49\u4e3a\uff1a"]}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:"#let touying-outline(enum-args: (:), padding: 0pt) = { .. }\n"})}),"\n",(0,t.jsxs)(n.p,{children:["\u4f60\u53ef\u4ee5\u901a\u8fc7 ",(0,t.jsx)(n.code,{children:"enum-args"})," \u4fee\u6539\u5185\u90e8 enum \u7684\u53c2\u6570\u3002"]}),"\n",(0,t.jsx)(n.p,{children:"\u5982\u679c\u4f60\u5bf9\u76ee\u5f55\u6709\u7740\u590d\u6742\u7684\u81ea\u5b9a\u4e49\u9700\u6c42\uff0c\u4f60\u53ef\u4ee5\u4f7f\u7528"}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:"#states.touying-final-sections(sections => ..)\n"})}),"\n",(0,t.jsx)(n.p,{children:"\u6b63\u5982 dewdrop \u4e3b\u9898\u6240\u505a\u7684\u90a3\u6837\u3002"})]})}function a(e={}){const{wrapper:n}={...(0,i.a)(),...e.components};return n?(0,t.jsx)(n,{...e,children:(0,t.jsx)(u,{...e})}):u(e)}},1151:(e,n,s)=>{s.d(n,{Z:()=>c,a:()=>l});var t=s(7294);const i={},o=t.createContext(i);function l(e){const n=t.useContext(o);return t.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function c(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:l(e.components),t.createElement(o.Provider,{value:n},e.children)}}}]);