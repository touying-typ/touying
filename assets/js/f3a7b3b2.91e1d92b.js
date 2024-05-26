"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[9916],{1075:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>r,contentTitle:()=>l,default:()=>h,frontMatter:()=>o,metadata:()=>a,toc:()=>d});var s=n(5893),i=n(1151);const o={sidebar_position:6},l="Global Settings",a={id:"global-settings",title:"Global Settings",description:"Global Styles",source:"@site/docs/global-settings.md",sourceDirName:".",slug:"/global-settings",permalink:"/touying/docs/next/global-settings",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/docs/global-settings.md",tags:[],version:"current",sidebarPosition:6,frontMatter:{sidebar_position:6},sidebar:"tutorialSidebar",previous:{title:"Page Layout",permalink:"/touying/docs/next/layout"},next:{title:"Multi-File Architecture",permalink:"/touying/docs/next/multi-file"}},r={},d=[{value:"Global Styles",id:"global-styles",level:2},{value:"Global Information",id:"global-information",level:2},{value:"State Initialization",id:"state-initialization",level:2}];function c(e){const t={admonition:"admonition",code:"code",h1:"h1",h2:"h2",img:"img",p:"p",pre:"pre",...(0,i.a)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(t.h1,{id:"global-settings",children:"Global Settings"}),"\n",(0,s.jsx)(t.h2,{id:"global-styles",children:"Global Styles"}),"\n",(0,s.jsxs)(t.p,{children:["For Touying, global styles refer to set rules or show rules that need to be applied everywhere, such as ",(0,s.jsx)(t.code,{children:"#set text(size: 20pt)"}),"."]}),"\n",(0,s.jsxs)(t.p,{children:["Themes in Touying encapsulate some of their own global styles, which are placed in ",(0,s.jsx)(t.code,{children:"#show: init"}),". For example, the university theme encapsulates the following:"]}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:"self.methods.init = (self: none, body) => {\n  set text(size: 25pt)\n  show footnote.entry: set text(size: .6em)\n  body\n}\n"})}),"\n",(0,s.jsxs)(t.p,{children:["If you are not a theme creator but want to add your own global styles to your slides, you can simply place them after ",(0,s.jsx)(t.code,{children:"#show: init"})," and before ",(0,s.jsx)(t.code,{children:"#show: slides"}),". For example, the metropolis theme recommends adding the following global styles:"]}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:'#let s = themes.metropolis.register(aspect-ratio: "16-9")\n#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)\n#show: init\n\n// global styles\n#set text(font: "Fira Sans", weight: "light", size: 20pt)\n#show math.equation: set text(font: "Fira Math")\n#set strong(delta: 100)\n#set par(justify: true)\n#show strong: alert\n\n#let (slide, empty-slide, title-slide, new-section-slide, focus-slide) = utils.slides(s)\n#show: slides\n'})}),"\n",(0,s.jsxs)(t.p,{children:["However, note that you should not use ",(0,s.jsx)(t.code,{children:"#set page(..)"}),". Instead, modify ",(0,s.jsx)(t.code,{children:"s.page-args"})," and ",(0,s.jsx)(t.code,{children:"s.padding"}),", for example:"]}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:"#(s.page-args += (\n  margin: (x: 0em, y: 2em),\n  header: align(top)[Header],\n  footer: align(bottom)[Footer],\n  header-ascent: 0em,\n  footer-descent: 0em,\n))\n#(s.padding += (x: 4em, y: 0em))\n"})}),"\n",(0,s.jsx)(t.h2,{id:"global-information",children:"Global Information"}),"\n",(0,s.jsx)(t.p,{children:"Like Beamer, Touying, through an OOP-style unified API design, can help you better maintain global information, allowing you to easily switch between different themes. Global information is a typical example of this."}),"\n",(0,s.jsx)(t.p,{children:"You can set the title, subtitle, author, date, and institution information for slides using:"}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:"#let s = (s.methods.info)(\n  self: s,\n  title: [Title],\n  subtitle: [Subtitle],\n  author: [Authors],\n  date: datetime.today(),\n  institution: [Institution],\n)\n"})}),"\n",(0,s.jsxs)(t.p,{children:["In subsequent slides, you can access them through ",(0,s.jsx)(t.code,{children:"s.info"})," or ",(0,s.jsx)(t.code,{children:"self.info"}),"."]}),"\n",(0,s.jsx)(t.p,{children:"This information is generally used in the title-slide, header, and footer of the theme, for example:"}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:'#let s = themes.metropolis.register(aspect-ratio: "16-9", footer: self => self.info.institution)\n'})}),"\n",(0,s.jsxs)(t.p,{children:["The ",(0,s.jsx)(t.code,{children:"date"})," can accept ",(0,s.jsx)(t.code,{children:"datetime"})," format or ",(0,s.jsx)(t.code,{children:"content"})," format, and the display format for the ",(0,s.jsx)(t.code,{children:"datetime"})," format can be changed using:"]}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:'#let s = (s.methods.datetime-format)(self: s, "[year]-[month]-[day]")\n'})}),"\n",(0,s.jsxs)(t.admonition,{title:"Principle",type:"tip",children:[(0,s.jsx)(t.p,{children:"Here, we will introduce a bit of OOP concept in Touying."}),(0,s.jsxs)(t.p,{children:["You should know that Typst is a typesetting language that supports incremental rendering, which means Typst caches the results of previous function calls. This requires that Typst consists of pure functions, meaning functions that do not change external variables. Thus, it is challenging to modify a global variable in the true sense, even with the use of ",(0,s.jsx)(t.code,{children:"state"})," or ",(0,s.jsx)(t.code,{children:"counter"}),". This would require the use of ",(0,s.jsx)(t.code,{children:"locate"})," with callback functions to obtain the values inside, and this approach would have a significant impact on performance."]}),(0,s.jsxs)(t.p,{children:["Touying does not use ",(0,s.jsx)(t.code,{children:"state"})," or ",(0,s.jsx)(t.code,{children:"counter"})," and does not violate the principle of pure functions in Typst. Instead, it uses a clever approach in an object-oriented style, maintaining a global singleton ",(0,s.jsx)(t.code,{children:"s"}),". In Touying, an object refers to a Typst dictionary with its own member variables and methods. We agree that methods all have a named parameter ",(0,s.jsx)(t.code,{children:"self"})," for passing the object itself, and methods are placed in the ",(0,s.jsx)(t.code,{children:".methods"})," domain. With this concept, it becomes easier to write methods to update ",(0,s.jsx)(t.code,{children:"info"}),":"]}),(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:"#let s = (\n  info: (:),\n  methods: (\n    // update info\n    info: (self: none, ..args) => {\n      self.info += args.named()\n      self\n    },\n  )\n)\n\n#let s = (s.methods.info)(self: s, title: [title])\n\nTitle is #s.info.title\n"})}),(0,s.jsxs)(t.p,{children:["Now you can understand the purpose of the ",(0,s.jsx)(t.code,{children:"utils.methods()"})," function: to bind ",(0,s.jsx)(t.code,{children:"self"})," to all methods of ",(0,s.jsx)(t.code,{children:"s"})," and return it, simplifying the subsequent usage through unpacking syntax."]}),(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:"#let (init, slides, alert) = utils.methods(s)\n"})})]}),"\n",(0,s.jsx)(t.h2,{id:"state-initialization",children:"State Initialization"}),"\n",(0,s.jsxs)(t.p,{children:["In general, the two ways mentioned above are sufficient for adding global settings. However, there are still situations where we need to initialize counters or states. If you place this code before ",(0,s.jsx)(t.code,{children:"#show: slides"}),", a blank page will be created, which is something we don't want to see. In such cases, you can use the ",(0,s.jsx)(t.code,{children:"s.methods.append-preamble"})," method. For example, when using the codly package:"]}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:'#import "@preview/touying:0.4.1": *\n#import "@preview/codly:0.2.0": *\n\n#let s = themes.simple.register(aspect-ratio: "16-9")\n#let s = (s.methods.append-preamble)(self: s)[\n  #codly(languages: (\n    rust: (name: "Rust", icon: "\\u{fa53}", color: rgb("#CE412B")),\n  ))\n]\n#let (init, slides) = utils.methods(s)\n#show heading.where(level: 2): set block(below: 1em)\n#show: init\n#show: codly-init.with()\n\n#let (slide, empty-slide) = utils.slides(s)\n#show: slides\n\n#slide[\n  == First slide\n\n  #raw(lang: "rust", block: true,\n`pub fn main() {\n  println!("Hello, world!");\n}`.text)\n]\n'})}),"\n",(0,s.jsx)(t.p,{children:(0,s.jsx)(t.img,{src:"https://github.com/touying-typ/touying/assets/34951714/0be2fbaf-cc03-4776-932f-259503d5e23a",alt:"image"})}),"\n",(0,s.jsx)(t.p,{children:"Or when configuring Pdfpc:"}),"\n",(0,s.jsx)(t.pre,{children:(0,s.jsx)(t.code,{className:"language-typst",children:'// Pdfpc configuration\n// typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc\n#let s = (s.methods.append-preamble)(self: s, pdfpc.config(\n  duration-minutes: 30,\n  start-time: datetime(hour: 14, minute: 10, second: 0),\n  end-time: datetime(hour: 14, minute: 40, second: 0),\n  last-minutes: 5,\n  note-font-size: 12,\n  disable-markdown: false,\n  default-transition: (\n    type: "push",\n    duration-seconds: 2,\n    angle: ltr,\n    alignment: "vertical",\n    direction: "inward",\n  ),\n))\n'})})]})}function h(e={}){const{wrapper:t}={...(0,i.a)(),...e.components};return t?(0,s.jsx)(t,{...e,children:(0,s.jsx)(c,{...e})}):c(e)}},1151:(e,t,n)=>{n.d(t,{Z:()=>a,a:()=>l});var s=n(7294);const i={},o=s.createContext(i);function l(e){const t=s.useContext(o);return s.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function a(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:l(e.components),s.createElement(o.Provider,{value:t},e.children)}}}]);