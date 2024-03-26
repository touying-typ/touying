"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[7190],{7022:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>r,contentTitle:()=>l,default:()=>u,frontMatter:()=>o,metadata:()=>c,toc:()=>d});var s=n(5893),i=n(1151);const o={sidebar_position:3},l="Sections and Subsections",c={id:"sections",title:"Sections and Subsections",description:"Structure",source:"@site/docs/sections.md",sourceDirName:".",slug:"/sections",permalink:"/touying/docs/next/sections",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/docs/sections.md",tags:[],version:"current",sidebarPosition:3,frontMatter:{sidebar_position:3},sidebar:"tutorialSidebar",previous:{title:"Getting Started",permalink:"/touying/docs/next/start"},next:{title:"Code Style",permalink:"/touying/docs/next/code-styles"}},r={},d=[{value:"Structure",id:"structure",level:2},{value:"Table of Contents",id:"table-of-contents",level:2}];function a(e){const t={code:"code",h1:"h1",h2:"h2",img:"img",p:"p",pre:"pre",...(0,i.a)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(t.h1,{id:"sections-and-subsections",children:"Sections and Subsections"}),"\n",(0,s.jsx)(t.h2,{id:"structure",children:"Structure"}),"\n",(0,s.jsx)(t.p,{children:"Similar to Beamer, Touying also has the concept of sections and subsections."}),"\n",(0,s.jsx)(t.p,{children:"Generally, level 1, level 2, and level 3 headings correspond to section, subsection, and title, respectively, as in the dewdrop theme."}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:'#import "@preview/touying:0.3.3": *\n\n#let s = themes.dewdrop.register()\n#let (init, slides) = utils.methods(s)\n#show: init\n\n#let (slide, empty-slide) = utils.slides(s)\n#show: slides\n\n= Section\n\n== Subsection\n\n=== Title\n\nHello, Touying!\n'})}),"\n",(0,s.jsx)(t.p,{children:(0,s.jsx)(t.img,{src:"https://github.com/touying-typ/touying/assets/34951714/1574e74d-25c1-418f-a84f-b974f42edae5",alt:"image"})}),"\n",(0,s.jsx)(t.p,{children:"However, often we don't need subsections, and we can use level 1 and level 2 headings to correspond to section and title, as in the university theme."}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:'#import "@preview/touying:0.3.3": *\n\n#let s = themes.university.register()\n#let (init, slides) = utils.methods(s)\n#show: init\n\n#let (slide, empty-slide) = utils.slides(s)\n#show: slides\n\n= Section\n\n== Title\n\nHello, Touying!\n'})}),"\n",(0,s.jsx)(t.p,{children:(0,s.jsx)(t.img,{src:"https://github.com/touying-typ/touying/assets/34951714/9dd77c98-9c08-4811-872e-092bbdebf394",alt:"image"})}),"\n",(0,s.jsxs)(t.p,{children:["In fact, we can control this behavior through the ",(0,s.jsx)(t.code,{children:"slide-level"})," parameter of the ",(0,s.jsx)(t.code,{children:"slides"})," function. ",(0,s.jsx)(t.code,{children:"slide-level"})," represents the complexity of the nested structure, starting from 0. For example, ",(0,s.jsx)(t.code,{children:"#show: slides.with(slide-level: 2)"})," is equivalent to the section, subsection, and title structure; while ",(0,s.jsx)(t.code,{children:"#show: slides.with(slide-level: 1)"})," is equivalent to the section and title structure."]}),"\n",(0,s.jsx)(t.h2,{id:"table-of-contents",children:"Table of Contents"}),"\n",(0,s.jsx)(t.p,{children:"Displaying a table of contents in Touying is straightforward:"}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:'#import "@preview/touying:0.3.3": *\n\n#let s = themes.simple.register()\n#let (init, slides, alert, touying-outline) = utils.methods(s)\n#show: init\n\n#let (slide, empty-slide) = utils.slides(s)\n#show: slides.with(slide-level: 2)\n\n= Section\n\n== Subsection\n\n=== Title\n\n==== Table of contents\n\n#touying-outline()\n'})}),"\n",(0,s.jsx)(t.p,{children:(0,s.jsx)(t.img,{src:"https://github.com/touying-typ/touying/assets/34951714/3cc09550-d3cc-40c2-a315-22ca8173798f",alt:"image"})}),"\n",(0,s.jsxs)(t.p,{children:["Where the definition of ",(0,s.jsx)(t.code,{children:"touying-outline()"})," is:"]}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:"#let touying-outline(enum-args: (:), padding: 0pt) = { .. }\n"})}),"\n",(0,s.jsxs)(t.p,{children:["You can modify the parameters of the internal enum through ",(0,s.jsx)(t.code,{children:"enum-args"}),"."]}),"\n",(0,s.jsx)(t.p,{children:"If you have complex custom requirements for the table of contents, you can use:"}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:"#states.touying-final-sections(sections => ..)\n"})}),"\n",(0,s.jsx)(t.p,{children:"As done in the dewdrop theme."})]})}function u(e={}){const{wrapper:t}={...(0,i.a)(),...e.components};return t?(0,s.jsx)(t,{...e,children:(0,s.jsx)(a,{...e})}):a(e)}},1151:(e,t,n)=>{n.d(t,{Z:()=>c,a:()=>l});var s=n(7294);const i={},o=s.createContext(i);function l(e){const t=s.useContext(o);return s.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function c(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:l(e.components),s.createElement(o.Provider,{value:t},e.children)}}}]);