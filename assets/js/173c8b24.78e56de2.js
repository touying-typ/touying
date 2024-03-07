"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[4733],{6130:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>d,contentTitle:()=>l,default:()=>h,frontMatter:()=>o,metadata:()=>r,toc:()=>a});var s=t(5893),i=t(1151);const o={sidebar_position:2},l="Metropolis Theme",r={id:"themes/metropolis",title:"Metropolis Theme",description:"image",source:"@site/versioned_docs/version-0.3.x/themes/metropolis.md",sourceDirName:"themes",slug:"/themes/metropolis",permalink:"/touying/docs/themes/metropolis",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/versioned_docs/version-0.3.x/themes/metropolis.md",tags:[],version:"0.3.x",sidebarPosition:2,frontMatter:{sidebar_position:2},sidebar:"tutorialSidebar",previous:{title:"Simple Theme",permalink:"/touying/docs/themes/simple"},next:{title:"Dewdrop Theme",permalink:"/touying/docs/themes/dewdrop"}},d={},a=[{value:"Initialization",id:"initialization",level:2},{value:"Color Theme",id:"color-theme",level:2},{value:"Slide Function Family",id:"slide-function-family",level:2},{value:"<code>slides</code> Function",id:"slides-function",level:2},{value:"Example",id:"example",level:2}];function c(e){const n={a:"a",code:"code",h1:"h1",h2:"h2",hr:"hr",img:"img",li:"li",p:"p",pre:"pre",ul:"ul",...(0,i.a)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(n.h1,{id:"metropolis-theme",children:"Metropolis Theme"}),"\n",(0,s.jsx)(n.p,{children:(0,s.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/383ceb22-f696-4450-83a6-c0f17e4597e1",alt:"image"})}),"\n",(0,s.jsxs)(n.p,{children:["This theme draws inspiration from Matthias Vogelgesang's ",(0,s.jsx)(n.a,{href:"https://github.com/matze/mtheme",children:"Metropolis beamer"})," theme and has been modified by ",(0,s.jsx)(n.a,{href:"https://github.com/Enivex",children:"Enivex"}),"."]}),"\n",(0,s.jsx)(n.p,{children:"The Metropolis theme is elegant and suitable for everyday use. It is recommended to have Fira Sans and Fira Math fonts installed on your computer for the best results."}),"\n",(0,s.jsx)(n.h2,{id:"initialization",children:"Initialization"}),"\n",(0,s.jsx)(n.p,{children:"You can initialize it using the following code:"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-typst",children:'#import "@preview/touying:0.3.1": *\n\n#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)\n#let s = (s.methods.info)(\n  self: s,\n  title: [Title],\n  subtitle: [Subtitle],\n  author: [Authors],\n  date: datetime.today(),\n  institution: [Institution],\n)\n#let (init, slides, touying-outline, alert) = utils.methods(s)\n#show: init\n\n#show strong: alert\n\n#let (slide, title-slide, new-section-slide, focus-slide) = utils.slides(s)\n#show: slides\n'})}),"\n",(0,s.jsxs)(n.p,{children:["The ",(0,s.jsx)(n.code,{children:"register"})," function takes the following parameters:"]}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.code,{children:"aspect-ratio"}),': The aspect ratio of the slides, either "16-9" or "4-3," defaulting to "16-9."']}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.code,{children:"header"}),": Content displayed in the header, defaulting to ",(0,s.jsx)(n.code,{children:"states.current-section-title"}),", or it can be passed as a function like ",(0,s.jsx)(n.code,{children:"self => self.info.title"}),"."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.code,{children:"footer"}),": Content displayed in the footer, defaulting to ",(0,s.jsx)(n.code,{children:"[]"}),", or it can be passed as a function like ",(0,s.jsx)(n.code,{children:"self => self.info.author"}),"."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.code,{children:"footer-right"}),": Content displayed on the right side of the footer, defaulting to ",(0,s.jsx)(n.code,{children:'states.slide-counter.display() + " / " + states.last-slide-number'}),"."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.code,{children:"footer-progress"}),": Whether to show the progress bar at the bottom of the slide, defaulting to ",(0,s.jsx)(n.code,{children:"true"}),"."]}),"\n"]}),"\n",(0,s.jsxs)(n.p,{children:["The Metropolis theme also provides an ",(0,s.jsx)(n.code,{children:"#alert[..]"})," function, which you can use with ",(0,s.jsx)(n.code,{children:"#show strong: alert"})," using the ",(0,s.jsx)(n.code,{children:"*alert text*"})," syntax."]}),"\n",(0,s.jsx)(n.h2,{id:"color-theme",children:"Color Theme"}),"\n",(0,s.jsx)(n.p,{children:"Metropolis uses the following default color theme:"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-typst",children:'#let s = (s.methods.colors)(\n  self: s,\n  neutral-lightest: rgb("#fafafa"),\n  primary-dark: rgb("#23373b"),\n  secondary-light: rgb("#eb811b"),\n  secondary-lighter: rgb("#d6c6b7"),\n)\n'})}),"\n",(0,s.jsxs)(n.p,{children:["You can modify this color theme using ",(0,s.jsx)(n.code,{children:"#let s = (s.methods.colors)(self: s, ..)"}),"."]}),"\n",(0,s.jsx)(n.h2,{id:"slide-function-family",children:"Slide Function Family"}),"\n",(0,s.jsx)(n.p,{children:"The Metropolis theme provides a variety of custom slide functions:"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-typst",children:"#title-slide(extra: none, ..args)\n"})}),"\n",(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.code,{children:"title-slide"})," reads information from ",(0,s.jsx)(n.code,{children:"self.info"})," for display, and you can also pass in an ",(0,s.jsx)(n.code,{children:"extra"})," parameter to display additional information."]}),"\n",(0,s.jsx)(n.hr,{}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-typst",children:"#slide(\n  repeat: auto,\n  setting: body => body,\n  composer: utils.side-by-side,\n  section: none,\n  subsection: none,\n  // metropolis theme\n  title: auto,\n  footer: auto,\n  align: horizon,\n)[\n  ...\n]\n"})}),"\n",(0,s.jsx)(n.p,{children:"A default slide with headers and footers, where the title defaults to the current section title, and the footer is what you set."}),"\n",(0,s.jsx)(n.hr,{}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-typst",children:"#focus-slide[\n  ...\n]\n"})}),"\n",(0,s.jsxs)(n.p,{children:["Used to draw attention, with the background color set to ",(0,s.jsx)(n.code,{children:"self.colors.primary-dark"}),"."]}),"\n",(0,s.jsx)(n.hr,{}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-typst",children:"#new-section-slide(short-title: auto, title)\n"})}),"\n",(0,s.jsx)(n.p,{children:"Creates a new section with the given title."}),"\n",(0,s.jsxs)(n.h2,{id:"slides-function",children:[(0,s.jsx)(n.code,{children:"slides"})," Function"]}),"\n",(0,s.jsxs)(n.p,{children:["The ",(0,s.jsx)(n.code,{children:"slides"})," function has the following parameters:"]}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.code,{children:"title-slide"}),": Defaults to ",(0,s.jsx)(n.code,{children:"true"}),"."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.code,{children:"outline-slide"}),": Defaults to ",(0,s.jsx)(n.code,{children:"true"}),"."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.code,{children:"slide-level"}),": Defaults to ",(0,s.jsx)(n.code,{children:"1"}),"."]}),"\n"]}),"\n",(0,s.jsxs)(n.p,{children:["You can set these using ",(0,s.jsx)(n.code,{children:"#show: slides.with(..)"}),"."]}),"\n",(0,s.jsxs)(n.p,{children:["PS: You can modify the outline title using ",(0,s.jsx)(n.code,{children:"#(s.outline-title = [Outline])"}),"."]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-typst",children:'#import "@preview/touying:0.3.1": *\n\n#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)\n#let s = (s.methods.info)(\n  self: s,\n  title: [Title],\n  subtitle: [Subtitle],\n  author: [Authors],\n  date: datetime.today(),\n  institution: [Institution],\n)\n#let s = (s.methods.enable-transparent-cover)(self: s)\n#let (init, slide, slides, title-slide, new-section-slide, focus-slide, touying-outline, alert) = utils.methods(s)\n#show: init\n\n#show strong: alert\n\n#show: slides\n\n= Title\n\n== First Slide\n\nHello, Touying!\n\n#pause\n\nHello, Typst!\n'})}),"\n",(0,s.jsx)(n.p,{children:(0,s.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/4ab45ee6-09f7-498b-b349-e889d6e42e3e",alt:"image"})}),"\n",(0,s.jsx)(n.h2,{id:"example",children:"Example"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-typst",children:'#import "@preview/touying:0.3.1": *\n\n#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)\n#let s = (s.methods.info)(\n  self: s,\n  title: [Title],\n  subtitle: [Subtitle],\n  author: [Authors],\n  date: datetime.today(),\n  institution: [Institution],\n)\n#let (init, slides, touying-outline, alert) = utils.methods(s)\n#show: init\n\n#set text(font: "Fira Sans", weight: "light", size: 20pt)\n#show math.equation: set text(font: "Fira Math")\n#set strong(delta: 100)\n#set par(justify: true)\n#show strong: alert\n\n#let (slide, title-slide, new-section-slide, focus-slide) = utils.slides(s)\n#show: slides\n\n= First Section\n\n#slide[\n  A slide without a title but with some *important* information.\n]\n\n== A long long long long long long long long long long long long long long long long long long long long long long long long Title\n\n#slide[\n  A slide with equation:\n\n  $ x_(n+1) = (x_n + a/x_n) / 2 $\n\n  #lorem(200)\n]\n\n= Second Section\n\n#focus-slide[\n  Wake up!\n]\n\n== Simple Animation\n\n#slide[\n  A simple #pause dynamic slide with #alert[alert]\n\n  #pause\n  \n  text.\n]\n\n// appendix by freezing last-slide-number\n#let s = (s.methods.appendix)(self: s)\n#let (slide,) = utils.slides(s)\n\n= Appendix\n\n#slide[\n  Appendix.\n]\n'})})]})}function h(e={}){const{wrapper:n}={...(0,i.a)(),...e.components};return n?(0,s.jsx)(n,{...e,children:(0,s.jsx)(c,{...e})}):c(e)}},1151:(e,n,t)=>{t.d(n,{Z:()=>r,a:()=>l});var s=t(7294);const i={},o=s.createContext(i);function l(e){const n=s.useContext(o);return s.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function r(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:l(e.components),s.createElement(o.Provider,{value:n},e.children)}}}]);