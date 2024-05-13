"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[8240],{3826:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>r,contentTitle:()=>l,default:()=>u,frontMatter:()=>o,metadata:()=>c,toc:()=>a});var i=t(5893),s=t(1151);const o={sidebar_position:7},l="Multi-File Architecture",c={id:"multi-file",title:"Multi-File Architecture",description:"Touying features a syntax as concise as native Typst documents, along with numerous customizable configuration options, yet it still maintains real-time incremental compilation performance, making it suitable for writing large-scale slides.",source:"@site/versioned_docs/version-0.4.0+/multi-file.md",sourceDirName:".",slug:"/multi-file",permalink:"/touying/docs/multi-file",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/versioned_docs/version-0.4.0+/multi-file.md",tags:[],version:"0.4.0+",sidebarPosition:7,frontMatter:{sidebar_position:7},sidebar:"tutorialSidebar",previous:{title:"Global Settings",permalink:"/touying/docs/global-settings"},next:{title:"Dynamic Slides",permalink:"/touying/docs/category/dynamic-slides"}},r={},a=[{value:"Configuration and Content Separation",id:"configuration-and-content-separation",level:2},{value:"Multiple Sections",id:"multiple-sections",level:2}];function d(e){const n={code:"code",h1:"h1",h2:"h2",p:"p",pre:"pre",...(0,s.a)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(n.h1,{id:"multi-file-architecture",children:"Multi-File Architecture"}),"\n",(0,i.jsx)(n.p,{children:"Touying features a syntax as concise as native Typst documents, along with numerous customizable configuration options, yet it still maintains real-time incremental compilation performance, making it suitable for writing large-scale slides."}),"\n",(0,i.jsx)(n.p,{children:"If you need to write a large set of slides, such as a course manual spanning tens or hundreds of pages, you can also try Touying's multi-file architecture."}),"\n",(0,i.jsx)(n.h2,{id:"configuration-and-content-separation",children:"Configuration and Content Separation"}),"\n",(0,i.jsxs)(n.p,{children:["A simple Touying multi-file architecture consists of three files: a global configuration file ",(0,i.jsx)(n.code,{children:"globals.typ"}),", a main entry file ",(0,i.jsx)(n.code,{children:"main.typ"}),", and a content file ",(0,i.jsx)(n.code,{children:"content.typ"})," for storing the actual content."]}),"\n",(0,i.jsxs)(n.p,{children:["These three files are separated to allow both ",(0,i.jsx)(n.code,{children:"main.typ"})," and ",(0,i.jsx)(n.code,{children:"content.typ"})," to import ",(0,i.jsx)(n.code,{children:"globals.typ"})," without causing circular references."]}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.code,{children:"globals.typ"})," can be used to store some global custom functions and initialize Touying themes:"]}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:'// globals.typ\n#import "@preview/touying:0.4.0": *\n\n#let s = themes.university.register(aspect-ratio: "16-9")\n#let s = (s.methods.numbering)(self: s, section: "1.", "1.1")\n#let s = (s.methods.info)(\n  self: s,\n  title: [Title],\n  subtitle: [Subtitle],\n  author: [Authors],\n  date: datetime.today(),\n  institution: [Institution],\n)\n#let (init, slides, touying-outline, alert) = utils.methods(s)\n#let (slide, empty-slide, title-slide, focus-slide, matrix-slide) = utils.slides(s)\n\n// as well as some utility functions\n'})}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.code,{children:"main.typ"}),", as the main entry point of the project, applies show rules by importing ",(0,i.jsx)(n.code,{children:"globals.typ"})," and includes ",(0,i.jsx)(n.code,{children:"content.typ"})," using ",(0,i.jsx)(n.code,{children:"#include"}),":"]}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:'// main.typ\n#import "/globals.typ": *\n\n#show: init\n#show strong: alert\n#show: slides\n\n#include "content.typ"\n'})}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.code,{children:"content.typ"})," is where you write the actual content:"]}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:'// content.typ\n#import "/globals.typ": *\n\n= The Section\n\n== Slide Title\n\nHello, Touying!\n\n#focus-slide[\n  Focus on me.\n]\n'})}),"\n",(0,i.jsx)(n.h2,{id:"multiple-sections",children:"Multiple Sections"}),"\n",(0,i.jsxs)(n.p,{children:["Implementing multiple sections is also straightforward. You only need to create a ",(0,i.jsx)(n.code,{children:"sections"})," directory and move the ",(0,i.jsx)(n.code,{children:"content.typ"})," file to the ",(0,i.jsx)(n.code,{children:"sections.typ"})," directory, for example:"]}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:'// main.typ\n#import "/globals.typ": *\n\n#show: init\n#show strong: alert\n#show: slides\n\n#include "sections/content.typ"\n// #include "sections/another-section.typ"\n'})}),"\n",(0,i.jsx)(n.p,{children:"And"}),"\n",(0,i.jsx)(n.pre,{children:(0,i.jsx)(n.code,{className:"language-typst",children:'// sections/content.typ\n#import "/globals.typ": *\n\n= The Section\n\n== Slide Title\n\nHello, Touying!\n\n#focus-slide[\n  Focus on me.\n]\n'})}),"\n",(0,i.jsx)(n.p,{children:"Now, you have learned how to use Touying to achieve a multi-file architecture for large-scale slides."})]})}function u(e={}){const{wrapper:n}={...(0,s.a)(),...e.components};return n?(0,i.jsx)(n,{...e,children:(0,i.jsx)(d,{...e})}):d(e)}},1151:(e,n,t)=>{t.d(n,{Z:()=>c,a:()=>l});var i=t(7294);const s={},o=i.createContext(s);function l(e){const n=i.useContext(o);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function c(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(s):e.components||s:l(e.components),i.createElement(o.Provider,{value:n},e.children)}}}]);