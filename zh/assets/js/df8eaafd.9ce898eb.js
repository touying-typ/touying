"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[7146],{3484:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>d,contentTitle:()=>r,default:()=>h,frontMatter:()=>l,metadata:()=>o,toc:()=>c});var t=s(5893),i=s(1151);const l={sidebar_position:4},r="University \u4e3b\u9898",o={id:"themes/university",title:"University \u4e3b\u9898",description:"image",source:"@site/i18n/zh/docusaurus-plugin-content-docs/current/themes/university.md",sourceDirName:"themes",slug:"/themes/university",permalink:"/touying/zh/docs/themes/university",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/docs/themes/university.md",tags:[],version:"current",sidebarPosition:4,frontMatter:{sidebar_position:4},sidebar:"tutorialSidebar",previous:{title:"Dewdrop \u4e3b\u9898",permalink:"/touying/zh/docs/themes/dewdrop"},next:{title:"\u521b\u5efa\u81ea\u5df1\u7684\u4e3b\u9898",permalink:"/touying/zh/docs/build-your-own-theme"}},d={},c=[{value:"\u521d\u59cb\u5316",id:"\u521d\u59cb\u5316",level:2},{value:"\u989c\u8272\u4e3b\u9898",id:"\u989c\u8272\u4e3b\u9898",level:2},{value:"slide \u51fd\u6570\u65cf",id:"slide-\u51fd\u6570\u65cf",level:2},{value:"<code>slides</code> \u51fd\u6570",id:"slides-\u51fd\u6570",level:2},{value:"\u793a\u4f8b",id:"\u793a\u4f8b",level:2}];function a(e){const n={a:"a",code:"code",h1:"h1",h2:"h2",hr:"hr",img:"img",li:"li",p:"p",pre:"pre",ul:"ul",...(0,i.a)(),...e.components};return(0,t.jsxs)(t.Fragment,{children:[(0,t.jsx)(n.h1,{id:"university-\u4e3b\u9898",children:"University \u4e3b\u9898"}),"\n",(0,t.jsx)(n.p,{children:(0,t.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/a9023bb3-0ef2-45eb-b23c-f94cc68a6fdd",alt:"image"})}),"\n",(0,t.jsxs)(n.p,{children:["\u8fd9\u4e2a\u4e3b\u9898\u6765\u81ea ",(0,t.jsx)(n.a,{href:"https://github.com/drupol",children:"Pol Dellaiera"}),"\u3002"]}),"\n",(0,t.jsx)(n.h2,{id:"\u521d\u59cb\u5316",children:"\u521d\u59cb\u5316"}),"\n",(0,t.jsx)(n.p,{children:"\u4f60\u53ef\u4ee5\u901a\u8fc7\u4e0b\u9762\u7684\u4ee3\u7801\u6765\u521d\u59cb\u5316\uff1a"}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:'#import "@preview/touying:0.2.1": *\n\n#let s = themes.university.register(s, aspect-ratio: "16-9")\n#let s = (s.methods.info)(\n  self: s,\n  title: [Title],\n  subtitle: [Subtitle],\n  author: [Authors],\n  date: datetime.today(),\n  institution: [Institution],\n)\n#let (init, slide, slides, title-slide, focus-slide, matrix-slide, touying-outline, alert) = utils.methods(s)\n#show: init\n'})}),"\n",(0,t.jsxs)(n.p,{children:["\u5176\u4e2d ",(0,t.jsx)(n.code,{children:"register"})," \u63a5\u6536\u53c2\u6570:"]}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.code,{children:"aspect-ratio"}),': \u5e7b\u706f\u7247\u7684\u957f\u5bbd\u6bd4\u4e3a "16-9" \u6216 "4-3"\uff0c\u9ed8\u8ba4\u4e3a "16-9"\u3002']}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.code,{children:"progress-bar"}),": \u662f\u5426\u663e\u793a slide \u9876\u90e8\u7684\u8fdb\u5ea6\u6761\uff0c\u9ed8\u8ba4\u4e3a ",(0,t.jsx)(n.code,{children:"true"}),"\u3002"]}),"\n"]}),"\n",(0,t.jsxs)(n.p,{children:["\u5e76\u4e14 University \u4e3b\u9898\u4f1a\u63d0\u4f9b\u4e00\u4e2a ",(0,t.jsx)(n.code,{children:"#alert[..]"})," \u51fd\u6570\uff0c\u4f60\u53ef\u4ee5\u901a\u8fc7 ",(0,t.jsx)(n.code,{children:"#show strong: alert"})," \u6765\u4f7f\u7528 ",(0,t.jsx)(n.code,{children:"*alert text*"})," \u8bed\u6cd5\u3002"]}),"\n",(0,t.jsx)(n.h2,{id:"\u989c\u8272\u4e3b\u9898",children:"\u989c\u8272\u4e3b\u9898"}),"\n",(0,t.jsx)(n.p,{children:"University \u9ed8\u8ba4\u4f7f\u7528\u4e86"}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:'#let s = (s.methods.colors)(\n  self: s,\n  primary: rgb("#04364A"),\n  secondary: rgb("#176B87"),\n  tertiary: rgb("#448C95"),\n  neutral-lightest: rgb("#FBFEF9"),\n)\n'})}),"\n",(0,t.jsxs)(n.p,{children:["\u989c\u8272\u4e3b\u9898\uff0c\u4f60\u53ef\u4ee5\u901a\u8fc7 ",(0,t.jsx)(n.code,{children:"#let s = (s.methods.colors)(self: s, ..)"})," \u5bf9\u5176\u8fdb\u884c\u4fee\u6539\u3002"]}),"\n",(0,t.jsx)(n.h2,{id:"slide-\u51fd\u6570\u65cf",children:"slide \u51fd\u6570\u65cf"}),"\n",(0,t.jsx)(n.p,{children:"University \u4e3b\u9898\u63d0\u4f9b\u4e86\u4e00\u7cfb\u5217\u81ea\u5b9a\u4e49 slide \u51fd\u6570\uff1a"}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:"#title-slide(logo: none, authors: none, ..args)\n"})}),"\n",(0,t.jsxs)(n.p,{children:[(0,t.jsx)(n.code,{children:"title-slide"})," \u4f1a\u8bfb\u53d6 ",(0,t.jsx)(n.code,{children:"self.info"})," \u91cc\u7684\u4fe1\u606f\u7528\u4e8e\u663e\u793a\uff0c\u4f60\u4e5f\u53ef\u4ee5\u4e3a\u5176\u4f20\u5165 ",(0,t.jsx)(n.code,{children:"logo"})," \u53c2\u6570\u548c array \u7c7b\u578b\u7684 ",(0,t.jsx)(n.code,{children:"authors"})," \u53c2\u6570\u3002"]}),"\n",(0,t.jsx)(n.hr,{}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:"#slide(\n  repeat: auto,\n  setting: body => body,\n  composer: utils.side-by-side,\n  section: none,\n  subsection: none,\n  // university theme\n  title: none,\n  subtitle: none,\n  header: none,\n  footer: auto,\n  margin: (top: 2em, bottom: 1em, x: 0em),\n  padding: (x: 2em, y: .5em),\n)[\n  ...\n]\n"})}),"\n",(0,t.jsxs)(n.p,{children:["\u9ed8\u8ba4\u62e5\u6709\u6807\u9898\u548c\u9875\u811a\u7684\u666e\u901a slide \u51fd\u6570\uff0c\u5176\u4e2d ",(0,t.jsx)(n.code,{children:"title"})," \u9ed8\u8ba4\u4e3a\u5f53\u524d section title\uff0c\u9875\u811a\u4e3a\u60a8\u8bbe\u7f6e\u7684\u9875\u811a\u3002"]}),"\n",(0,t.jsx)(n.hr,{}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:"#focus-slide(background-img: ..., background-color: ...)[\n  ...\n]\n"})}),"\n",(0,t.jsxs)(n.p,{children:["\u7528\u4e8e\u5f15\u8d77\u89c2\u4f17\u7684\u6ce8\u610f\u529b\u3002\u9ed8\u8ba4\u80cc\u666f\u8272\u4e3a ",(0,t.jsx)(n.code,{children:"self.colors.primary"}),"\u3002"]}),"\n",(0,t.jsx)(n.hr,{}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:"#matrix-slide(columns: ..., rows: ...)[\n  ...\n][\n  ...\n]\n"})}),"\n",(0,t.jsxs)(n.p,{children:["\u53ef\u4ee5\u53c2\u8003 ",(0,t.jsx)(n.a,{href:"https://polylux.dev/book/themes/gallery/university.html",children:"\u6587\u6863"}),"\u3002"]}),"\n",(0,t.jsxs)(n.h2,{id:"slides-\u51fd\u6570",children:[(0,t.jsx)(n.code,{children:"slides"})," \u51fd\u6570"]}),"\n",(0,t.jsxs)(n.p,{children:[(0,t.jsx)(n.code,{children:"slides"})," \u51fd\u6570\u62e5\u6709\u53c2\u6570"]}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.code,{children:"title-slide"}),": \u9ed8\u8ba4\u4e3a ",(0,t.jsx)(n.code,{children:"true"}),"\u3002"]}),"\n"]}),"\n",(0,t.jsxs)(n.p,{children:["\u53ef\u4ee5\u901a\u8fc7 ",(0,t.jsx)(n.code,{children:"#show: slides.with(..)"})," \u7684\u65b9\u5f0f\u8bbe\u7f6e\u3002"]}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:'#import "@preview/touying:0.2.1": *\n\n#let s = themes.university.register(s, aspect-ratio: "16-9")\n#let s = (s.methods.info)(\n  self: s,\n  title: [Title],\n  subtitle: [Subtitle],\n  author: [Authors],\n  date: datetime.today(),\n  institution: [Institution],\n)\n#let (init, slide, slides, title-slide, focus-slide, matrix-slide, touying-outline, alert) = utils.methods(s)\n#show: init\n\n#show: slides\n\n= Title\n\n== First Slide\n\nHello, Touying!\n\n#pause\n\nHello, Typst!\n'})}),"\n",(0,t.jsx)(n.p,{children:(0,t.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/58971045-0b0d-46cb-acc2-caf766c2432d",alt:"image"})}),"\n",(0,t.jsx)(n.h2,{id:"\u793a\u4f8b",children:"\u793a\u4f8b"}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typst",children:'#import "@preview/touying:0.2.1": *\n\n#let s = themes.university.register(s, aspect-ratio: "16-9")\n#let s = (s.methods.info)(\n  self: s,\n  title: [Title],\n  subtitle: [Subtitle],\n  author: [Authors],\n  date: datetime.today(),\n  institution: [Institution],\n)\n#let (init, slide, slides, title-slide, focus-slide, matrix-slide, touying-outline, alert) = utils.methods(s)\n#show: init\n\n#title-slide(authors: ("Author A", "Author B"))\n\n#slide(title: [Slide title], section: [The section])[\n  #lorem(40)\n]\n\n#slide(title: [Slide title], subtitle: emph[What is the problem?])[\n  #lorem(40)\n]\n\n#focus-slide[\n  *Another variant with an image in background...*\n]\n\n#matrix-slide[\n  left\n][\n  middle\n][\n  right\n]\n\n#matrix-slide(columns: 1)[\n  top\n][\n  bottom\n]\n\n#matrix-slide(columns: (1fr, 2fr, 1fr), ..(lorem(8),) * 9)\n'})})]})}function h(e={}){const{wrapper:n}={...(0,i.a)(),...e.components};return n?(0,t.jsx)(n,{...e,children:(0,t.jsx)(a,{...e})}):a(e)}},1151:(e,n,s)=>{s.d(n,{Z:()=>o,a:()=>r});var t=s(7294);const i={},l=t.createContext(i);function r(e){const n=t.useContext(l);return t.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function o(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:r(e.components),t.createElement(l.Provider,{value:n},e.children)}}}]);