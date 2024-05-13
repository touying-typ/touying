"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[2365],{3631:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>r,contentTitle:()=>d,default:()=>h,frontMatter:()=>l,metadata:()=>o,toc:()=>c});var i=s(5893),t=s(1151);const l={sidebar_position:5},d="Aqua \u4e3b\u9898",o={id:"themes/aqua",title:"Aqua \u4e3b\u9898",description:"image",source:"@site/i18n/zh/docusaurus-plugin-content-docs/version-0.4.0+/themes/aqua.md",sourceDirName:"themes",slug:"/themes/aqua",permalink:"/touying/zh/docs/0.4.0+/themes/aqua",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/versioned_docs/version-0.4.0+/themes/aqua.md",tags:[],version:"0.4.0+",sidebarPosition:5,frontMatter:{sidebar_position:5},sidebar:"tutorialSidebar",previous:{title:"University \u4e3b\u9898",permalink:"/touying/zh/docs/0.4.0+/themes/university"},next:{title:"\u521b\u5efa\u81ea\u5df1\u7684\u4e3b\u9898",permalink:"/touying/zh/docs/0.4.0+/build-your-own-theme"}},r={},c=[{value:"\u521d\u59cb\u5316",id:"\u521d\u59cb\u5316",level:2},{value:"\u989c\u8272\u4e3b\u9898",id:"\u989c\u8272\u4e3b\u9898",level:2},{value:"slide \u51fd\u6570\u65cf",id:"slide-\u51fd\u6570\u65cf",level:2},{value:"<code>slides</code> \u51fd\u6570",id:"slides-\u51fd\u6570",level:2},{value:"\u793a\u4f8b",id:"\u793a\u4f8b",level:2}];function a(e){const n={a:"a",code:"code",h1:"h1",h2:"h2",hr:"hr",img:"img",li:"li",p:"p",pre:"pre",ul:"ul",...(0,t.a)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(n.h1,{id:"aqua-\u4e3b\u9898",children:"Aqua \u4e3b\u9898"}),"\n",(0,i.jsx)(n.p,{children:(0,i.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/5f9b3c99-a22a-4f3d-a266-93dd75997593",alt:"image"})}),"\n",(0,i.jsxs)(n.p,{children:["\u8fd9\u4e2a\u4e3b\u9898\u7531 ",(0,i.jsx)(n.a,{href:"https://github.com/pride7",children:"@pride7"})," \u5236\u4f5c\uff0c\u5b83\u7684\u7f8e\u4e3d\u80cc\u666f\u4e3a\u4f7f\u7528 Typst \u7684\u53ef\u89c6\u5316\u529f\u80fd\u5236\u4f5c\u7684\u77e2\u91cf\u56fe\u5f62\u3002"]}),"\n",(0,i.jsx)(n.h2,{id:"\u521d\u59cb\u5316",children:"\u521d\u59cb\u5316"}),"\n",(0,i.jsx)(n.p,{children:"\u4f60\u53ef\u4ee5\u901a\u8fc7\u4e0b\u9762\u7684\u4ee3\u7801\u6765\u521d\u59cb\u5316\uff1a"}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:'#import "@preview/touying:0.4.0": *\n\n#let s = themes.aqua.register(aspect-ratio: "16-9", lang: "en")\n#let s = (s.methods.info)(\n  self: s,\n  title: [Title],\n  subtitle: [Subtitle],\n  author: [Authors],\n  date: datetime.today(),\n  institution: [Institution],\n)\n#let (init, slides, touying-outline, alert) = utils.methods(s)\n#show: init\n\n#show strong: alert\n\n#let (slide, empty-slide, title-slide, outline-slide, focus-slide) = utils.slides(s)\n#show: slides\n'})}),"\n",(0,i.jsxs)(n.p,{children:["\u5176\u4e2d ",(0,i.jsx)(n.code,{children:"register"})," \u63a5\u6536\u53c2\u6570:"]}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.code,{children:"aspect-ratio"}),': \u5e7b\u706f\u7247\u7684\u957f\u5bbd\u6bd4\u4e3a "16-9" \u6216 "4-3"\uff0c\u9ed8\u8ba4\u4e3a "16-9"\u3002']}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.code,{children:"footer"}),": \u5c55\u793a\u5728\u9875\u811a\u53f3\u4fa7\u7684\u5185\u5bb9\uff0c\u9ed8\u8ba4\u4e3a ",(0,i.jsx)(n.code,{children:"states.slide-counter.display()"}),"\u3002"]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.code,{children:"lang"}),": \u8bed\u8a00\u914d\u7f6e\uff0c\u76ee\u524d\u53ea\u652f\u6301 ",(0,i.jsx)(n.code,{children:'"en"'})," \u548c ",(0,i.jsx)(n.code,{children:'"zh"'}),"\uff0c\u9ed8\u8ba4\u4e3a ",(0,i.jsx)(n.code,{children:'"en"'}),","]}),"\n"]}),"\n",(0,i.jsxs)(n.p,{children:["\u5e76\u4e14 Aqua \u4e3b\u9898\u4f1a\u63d0\u4f9b\u4e00\u4e2a ",(0,i.jsx)(n.code,{children:"#alert[..]"})," \u51fd\u6570\uff0c\u4f60\u53ef\u4ee5\u901a\u8fc7 ",(0,i.jsx)(n.code,{children:"#show strong: alert"})," \u6765\u4f7f\u7528 ",(0,i.jsx)(n.code,{children:"*alert text*"})," \u8bed\u6cd5\u3002"]}),"\n",(0,i.jsx)(n.h2,{id:"\u989c\u8272\u4e3b\u9898",children:"\u989c\u8272\u4e3b\u9898"}),"\n",(0,i.jsx)(n.p,{children:"Aqua \u9ed8\u8ba4\u4f7f\u7528\u4e86"}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:'#let s = (s.methods.colors)(\n  self: s,\n  primary: rgb("#003F88"),\n  primary-light: rgb("#2159A5"),\n  primary-lightest: rgb("#F2F4F8"),\n'})}),"\n",(0,i.jsxs)(n.p,{children:["\u989c\u8272\u4e3b\u9898\uff0c\u4f60\u53ef\u4ee5\u901a\u8fc7 ",(0,i.jsx)(n.code,{children:"#let s = (s.methods.colors)(self: s, ..)"})," \u5bf9\u5176\u8fdb\u884c\u4fee\u6539\u3002"]}),"\n",(0,i.jsx)(n.h2,{id:"slide-\u51fd\u6570\u65cf",children:"slide \u51fd\u6570\u65cf"}),"\n",(0,i.jsx)(n.p,{children:"Aqua \u4e3b\u9898\u63d0\u4f9b\u4e86\u4e00\u7cfb\u5217\u81ea\u5b9a\u4e49 slide \u51fd\u6570\uff1a"}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:"#title-slide(..args)\n"})}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.code,{children:"title-slide"})," \u4f1a\u8bfb\u53d6 ",(0,i.jsx)(n.code,{children:"self.info"})," \u91cc\u7684\u4fe1\u606f\u7528\u4e8e\u663e\u793a\u3002"]}),"\n",(0,i.jsx)(n.hr,{}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:"#let outline-slide(self: none, enum-args: (:), leading: 50pt)\n"})}),"\n",(0,i.jsx)(n.p,{children:"\u663e\u793a\u4e00\u4e2a\u5927\u7eb2\u9875\u3002"}),"\n",(0,i.jsx)(n.hr,{}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:"#slide(\n  repeat: auto,\n  setting: body => body,\n  composer: utils.side-by-side,\n  section: none,\n  subsection: none,\n  // Aqua theme\n  title: auto,\n)[\n  ...\n]\n"})}),"\n",(0,i.jsxs)(n.p,{children:["\u9ed8\u8ba4\u62e5\u6709\u6807\u9898\u548c\u9875\u811a\u7684\u666e\u901a slide \u51fd\u6570\uff0c\u5176\u4e2d ",(0,i.jsx)(n.code,{children:"title"})," \u9ed8\u8ba4\u4e3a\u5f53\u524d section title\u3002"]}),"\n",(0,i.jsx)(n.hr,{}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:"#focus-slide[\n  ...\n]\n"})}),"\n",(0,i.jsxs)(n.p,{children:["\u7528\u4e8e\u5f15\u8d77\u89c2\u4f17\u7684\u6ce8\u610f\u529b\u3002\u80cc\u666f\u8272\u4e3a ",(0,i.jsx)(n.code,{children:"self.colors.primary"}),"\u3002"]}),"\n",(0,i.jsx)(n.hr,{}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:"#new-section-slide(title)\n"})}),"\n",(0,i.jsx)(n.p,{children:"\u7528\u7ed9\u5b9a\u6807\u9898\u5f00\u542f\u4e00\u4e2a\u65b0\u7684 section\u3002"}),"\n",(0,i.jsxs)(n.h2,{id:"slides-\u51fd\u6570",children:[(0,i.jsx)(n.code,{children:"slides"})," \u51fd\u6570"]}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.code,{children:"slides"})," \u51fd\u6570\u62e5\u6709\u53c2\u6570"]}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.code,{children:"title-slide"}),": \u9ed8\u8ba4\u4e3a ",(0,i.jsx)(n.code,{children:"true"}),"\u3002"]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.code,{children:"outline-slide"}),": \u9ed8\u8ba4\u4e3a ",(0,i.jsx)(n.code,{children:"true"}),"\u3002"]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.code,{children:"slide-level"}),": \u9ed8\u8ba4\u4e3a ",(0,i.jsx)(n.code,{children:"1"}),"\u3002"]}),"\n"]}),"\n",(0,i.jsxs)(n.p,{children:["\u53ef\u4ee5\u901a\u8fc7 ",(0,i.jsx)(n.code,{children:"#show: slides.with(..)"})," \u7684\u65b9\u5f0f\u8bbe\u7f6e\u3002"]}),"\n",(0,i.jsxs)(n.p,{children:["PS: \u5176\u4e2d outline title \u53ef\u4ee5\u901a\u8fc7 ",(0,i.jsx)(n.code,{children:"#(s.outline-title = [Outline])"})," \u7684\u65b9\u5f0f\u4fee\u6539\u3002"]}),"\n",(0,i.jsxs)(n.p,{children:["\u4ee5\u53ca\u53ef\u4ee5\u901a\u8fc7 ",(0,i.jsx)(n.code,{children:"#(s.methods.touying-new-section-slide = none)"})," \u7684\u65b9\u5f0f\u5173\u95ed\u81ea\u52a8\u52a0\u5165 ",(0,i.jsx)(n.code,{children:"new-section-slide"})," \u7684\u529f\u80fd\u3002"]}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:'#import "@preview/touying:0.4.0": *\n\n#let s = themes.aqua.register(aspect-ratio: "16-9", lang: "en")\n#let s = (s.methods.info)(\n  self: s,\n  title: [Title],\n  subtitle: [Subtitle],\n  author: [Authors],\n  date: datetime.today(),\n  institution: [Institution],\n)\n#let (init, slides, touying-outline, alert) = utils.methods(s)\n#show: init\n\n#show strong: alert\n\n#let (slide, empty-slide, title-slide, outline-slide, focus-slide) = utils.slides(s)\n#show: slides\n\n= Title\n\n== First Slide\n\nHello, Touying!\n\n#pause\n\nHello, Typst!\n'})}),"\n",(0,i.jsx)(n.p,{children:(0,i.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/eea4df8d-d9fd-43ac-aaf7-bb459864a9ac",alt:"image"})}),"\n",(0,i.jsx)(n.h2,{id:"\u793a\u4f8b",children:"\u793a\u4f8b"}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:'#import "../lib.typ": *\n\n#let s = themes.aqua.register(aspect-ratio: "16-9", lang: "en")\n#let s = (s.methods.info)(\n  self: s,\n  title: [Title],\n  subtitle: [Subtitle],\n  author: [Authors],\n  date: datetime.today(),\n  institution: [Institution],\n)\n#let (init, slides, touying-outline, alert) = utils.methods(s)\n#show: init\n\n#show strong: alert\n\n#let (slide, empty-slide, title-slide, outline-slide, focus-slide) = utils.slides(s)\n#show: slides\n\n= The Section\n\n== Slide Title\n\n#slide[\n  #lorem(40)\n]\n\n#focus-slide[\n  Another variant with primary color in background...\n]\n\n== Summary\n\n#align(center + horizon)[\n  #set text(size: 3em, weight: "bold", s.colors.primary)\n  THANKS FOR ALL\n]\n'})})]})}function h(e={}){const{wrapper:n}={...(0,t.a)(),...e.components};return n?(0,i.jsx)(n,{...e,children:(0,i.jsx)(a,{...e})}):a(e)}},1151:(e,n,s)=>{s.d(n,{Z:()=>o,a:()=>d});var i=s(7294);const t={},l=i.createContext(t);function d(e){const n=i.useContext(l);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function o(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:d(e.components),i.createElement(l.Provider,{value:n},e.children)}}}]);