"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[8565],{2857:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>d,contentTitle:()=>s,default:()=>h,frontMatter:()=>a,metadata:()=>r,toc:()=>c});var o=t(5893),i=t(1151);const a={sidebar_position:5},s="Page Layout",r={id:"layout",title:"Page Layout",description:"Basic Concepts",source:"@site/docs/layout.md",sourceDirName:".",slug:"/layout",permalink:"/touying/docs/next/layout",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/docs/layout.md",tags:[],version:"current",sidebarPosition:5,frontMatter:{sidebar_position:5},sidebar:"tutorialSidebar",previous:{title:"Code Style",permalink:"/touying/docs/next/code-styles"},next:{title:"Global Settings",permalink:"/touying/docs/next/global-settings"}},d={},c=[{value:"Basic Concepts",id:"basic-concepts",level:2},{value:"Page Management",id:"page-management",level:2},{value:"Application: Adding a Logo",id:"application-adding-a-logo",level:2},{value:"Page Columns",id:"page-columns",level:2}];function l(e){const n={admonition:"admonition",code:"code",h1:"h1",h2:"h2",img:"img",li:"li",ol:"ol",p:"p",pre:"pre",strong:"strong",...(0,i.a)(),...e.components};return(0,o.jsxs)(o.Fragment,{children:[(0,o.jsx)(n.h1,{id:"page-layout",children:"Page Layout"}),"\n",(0,o.jsx)(n.h2,{id:"basic-concepts",children:"Basic Concepts"}),"\n",(0,o.jsx)(n.p,{children:"To create aesthetically pleasing slides using Typst, it is essential to understand Typst's page model correctly. If you don't care about customizing the page style, you can choose to skip this section. However, it is still recommended to go through this part."}),"\n",(0,o.jsx)(n.p,{children:"Here, we illustrate Typst's default page model with a specific example."}),"\n",(0,o.jsx)(n.pre,{children:(0,o.jsx)(n.code,{className:"language-typst",children:'#let container = rect.with(height: 100%, width: 100%, inset: 0pt)\n#let innerbox = rect.with(stroke: (dash: "dashed"))\n\n#set text(size: 30pt)\n#set page(\n  paper: "presentation-16-9",\n  header: container[#innerbox[Header]],\n  header-ascent: 30%,\n  footer: container[#innerbox[Footer]],\n  footer-descent: 30%,\n)\n#let padding = (x: 2em, y: 2em)\n\n#place(top + right)[Margin\u2192]\n#container[\n  #place[Padding]\n  #pad(..padding)[\n    #container[\n      #innerbox[Content]\n    ]\n  ]\n]\n'})}),"\n",(0,o.jsx)(n.p,{children:(0,o.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/6cbb1092-c733-41b6-a15d-822ce970ef13",alt:"image"})}),"\n",(0,o.jsx)(n.p,{children:"We need to distinguish the following concepts:"}),"\n",(0,o.jsxs)(n.ol,{children:["\n",(0,o.jsxs)(n.li,{children:[(0,o.jsx)(n.strong,{children:"Model:"})," Typst has a model similar to the CSS Box Model, divided into Margin, Padding, and Content. However, padding is not a property of ",(0,o.jsx)(n.code,{children:"set page(..)"})," but is obtained manually by adding ",(0,o.jsx)(n.code,{children:"#pad(..)"}),"."]}),"\n",(0,o.jsxs)(n.li,{children:[(0,o.jsx)(n.strong,{children:"Margin:"})," Margins, including top, bottom, left, and right, are the core of Typst's page model. Other properties are influenced by margins, especially Header and Footer, which are actually inside the Margin."]}),"\n",(0,o.jsxs)(n.li,{children:[(0,o.jsx)(n.strong,{children:"Padding:"})," Used to add additional space between Margin and Content."]}),"\n",(0,o.jsxs)(n.li,{children:[(0,o.jsx)(n.strong,{children:"Header:"})," The Header is the content at the top of the page, divided into container and innerbox. We can notice that the edge of the header container and padding does not align but has a certain gap. This gap is actually ",(0,o.jsx)(n.code,{children:"header-ascent: 30%"}),", and the percentage is relative to margin-top. Also, we notice that the header innerbox is actually located at the bottom left corner of the header container, meaning the innerbox defaults to ",(0,o.jsx)(n.code,{children:"#set align(left + bottom)"}),"."]}),"\n",(0,o.jsxs)(n.li,{children:[(0,o.jsx)(n.strong,{children:"Footer:"})," The Footer is the content at the bottom of the page, divided into container and innerbox. We can notice that the edge of the footer container and padding does not align but has a certain gap. This gap is actually ",(0,o.jsx)(n.code,{children:"footer-descent: 30%"}),", and the percentage is relative to margin-bottom. Also, we notice that the footer innerbox is actually located at the top left corner of the footer container, meaning the innerbox defaults to ",(0,o.jsx)(n.code,{children:"#set align(left + top)"}),"."]}),"\n",(0,o.jsxs)(n.li,{children:[(0,o.jsx)(n.strong,{children:"Place:"})," The ",(0,o.jsx)(n.code,{children:"place"})," function can achieve absolute positioning, relative to the parent container, without affecting other elements within the parent container. It can take parameters like ",(0,o.jsx)(n.code,{children:"alignment"}),", ",(0,o.jsx)(n.code,{children:"dx"}),", and ",(0,o.jsx)(n.code,{children:"dy"}),", making it suitable for placing decorative elements such as logos."]}),"\n"]}),"\n",(0,o.jsx)(n.p,{children:"Therefore, to apply Typst to create slides, we only need to set"}),"\n",(0,o.jsx)(n.pre,{children:(0,o.jsx)(n.code,{className:"language-typst",children:"#set page(\n  margin: (x: 0em, y: 2em),\n  header: align(top)[Header],\n  footer: align(bottom)[Footer],\n  header-ascent: 0em,\n  footer-descent: 0em,\n)\n#let padding = (x: 4em, y: 0em)\n"})}),"\n",(0,o.jsx)(n.p,{children:"For example, we have"}),"\n",(0,o.jsx)(n.pre,{children:(0,o.jsx)(n.code,{className:"language-typst",children:'#let container = rect.with(stroke: (dash: "dashed"), height: 100%, width: 100%, inset: 0pt)\n#let innerbox = rect.with(fill: rgb("#d0d0d0"))\n\n#set text(size: 30pt)\n#set page(\n  paper: "presentation-16-9",\n  margin: (x: 0em, y: 2em),\n  header: container[#align(top)[#innerbox(width: 100%)[Header]]],\n  header-ascent: 0em,\n  footer: container[#align(bottom)[#innerbox(width: 100%)[Footer]]],\n  footer-descent: 0em,\n)\n#let padding = (x: 4em, y: 0em)\n\n#place(top + right)[\u2191Margin]\n#container[\n  #place[Padding]\n  #pad(..padding)[\n    #container[\n      #innerbox[Content]\n    ]\n  ]\n]\n'})}),"\n",(0,o.jsx)(n.p,{children:(0,o.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/6127d231-86f3-4262-b7c6-b199d47ae12b",alt:"image"})}),"\n",(0,o.jsx)(n.h2,{id:"page-management",children:"Page Management"}),"\n",(0,o.jsxs)(n.p,{children:["Since using the ",(0,o.jsx)(n.code,{children:"set page(..)"})," command in Typst to modify page parameters creates a new page and cannot modify the current one, Touying chooses to maintain an ",(0,o.jsx)(n.code,{children:"s.page-args"})," member variable and an ",(0,o.jsx)(n.code,{children:"s.padding"})," member variable. Touying applies these parameters only when creating new slides, so users only need to focus on ",(0,o.jsx)(n.code,{children:"s.page-args"})," and ",(0,o.jsx)(n.code,{children:"s.padding"}),"."]}),"\n",(0,o.jsx)(n.p,{children:"For example, the previous example can be transformed into"}),"\n",(0,o.jsx)(n.pre,{children:(0,o.jsx)(n.code,{className:"language-typst",children:"#(s.page-args += (\n  margin: (x: 0em, y: 2em),\n  header: align(top)[Header],\n  footer: align(bottom)[Footer],\n  header-ascent: 0em,\n  footer-descent: 0em,\n))\n#(s.padding += (x: 4em, y: 0em))\n"})}),"\n",(0,o.jsx)(n.p,{children:"Similarly, if you are not satisfied with the header or footer style of a theme, you can use"}),"\n",(0,o.jsx)(n.pre,{children:(0,o.jsx)(n.code,{className:"language-typst",children:"#(s.page-args.footer = [Custom Footer])\n"})}),"\n",(0,o.jsxs)(n.p,{children:["to replace it. However, please note that if you replace the page parameters in this way, you need to place it before ",(0,o.jsx)(n.code,{children:"#let (slide,) = utils.slides(s)"}),", or you need to call ",(0,o.jsx)(n.code,{children:"#let (slide,) = utils.slides(s)"})," again."]}),"\n",(0,o.jsx)(n.admonition,{title:"Warning",type:"warning",children:(0,o.jsxs)(n.p,{children:["Therefore, you should not use the ",(0,o.jsx)(n.code,{children:"set page(..)"})," command on your own; instead, you should modify the ",(0,o.jsx)(n.code,{children:"s.page-args"})," member variable internally."]})}),"\n",(0,o.jsxs)(n.p,{children:["In this way, we can also query the current page parameters in real-time through ",(0,o.jsx)(n.code,{children:"s.page-args"}),". This is useful for some functions that need to get margin or the current page's background color, such as ",(0,o.jsx)(n.code,{children:"transparent-cover"}),". This is partly equivalent to the context get rule, and it is actually more convenient to use."]}),"\n",(0,o.jsx)(n.h2,{id:"application-adding-a-logo",children:"Application: Adding a Logo"}),"\n",(0,o.jsxs)(n.p,{children:["Adding a logo to slides is a very common but also a very versatile requirement. The difficulty lies in the fact that the required size and position of the logo often vary from person to person. Therefore, most of Touying's themes do not include configuration options for logos. But with the concepts of page layout mentioned in this section, we know that we can use the ",(0,o.jsx)(n.code,{children:"place"})," function in the header or footer to place a logo image."]}),"\n",(0,o.jsx)(n.p,{children:"For example, suppose we decide to add the GitHub icon to the metropolis theme. We can implement it like this:"}),"\n",(0,o.jsx)(n.pre,{children:(0,o.jsx)(n.code,{className:"language-typst",children:'#import "@preview/touying:0.3.1": *\n#import "@preview/octique:0.1.0": *\n\n#let s = themes.metropolis.register(s, aspect-ratio: "16-9")\n#(s.page-args.header = self => {\n  // display the original header\n  utils.call-or-display(self, s.page-args.header)\n  // place logo at the top-right\n  place(top + right, dx: -0.5em, dy: 0.3em)[\n    #octique("mark-github", color: rgb("#fafafa"), width: 1.5em, height: 1.5em)\n  ]\n})\n#let (init, slide) = utils.methods(s)\n#show: init\n\n#slide(title: [Title])[\n  Logo example.\n]\n'})}),"\n",(0,o.jsx)(n.p,{children:(0,o.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/055d77e7-5087-4248-b969-d8ef9d50c54b",alt:"image"})}),"\n",(0,o.jsxs)(n.p,{children:["Here, ",(0,o.jsx)(n.code,{children:"utils.call-or-display(self, body)"})," can be used to display ",(0,o.jsx)(n.code,{children:"body"})," as content or a callback function in the form ",(0,o.jsx)(n.code,{children:"self => content"}),"."]}),"\n",(0,o.jsx)(n.h2,{id:"page-columns",children:"Page Columns"}),"\n",(0,o.jsxs)(n.p,{children:["If you need to divide the page into two or three columns, you can use the ",(0,o.jsx)(n.code,{children:"compose"})," feature provided by the default ",(0,o.jsx)(n.code,{children:"slide"})," function in Touying. The simplest example is as follows:"]}),"\n",(0,o.jsx)(n.pre,{children:(0,o.jsx)(n.code,{className:"language-typst",children:"#slide[\n  First column.\n][\n  Second column.\n]\n"})}),"\n",(0,o.jsx)(n.p,{children:(0,o.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/a39f88a2-f1ba-4420-8f78-6a0fc644704e",alt:"image"})}),"\n",(0,o.jsxs)(n.p,{children:["If you need to change the way columns are composed, you can modify the ",(0,o.jsx)(n.code,{children:"composer"})," parameter of ",(0,o.jsx)(n.code,{children:"slide"}),". The default parameter is ",(0,o.jsx)(n.code,{children:"utils.with.side-by-side(columns: auto, gutter: 1em)"}),". If we want the left column to occupy the remaining width, we can use"]}),"\n",(0,o.jsx)(n.pre,{children:(0,o.jsx)(n.code,{className:"language-typst",children:"#slide(composer: utils.side-by-side.with(columns: (1fr, auto), gutter: 1em))[\n  First column.\n][\n  Second column.\n]\n"})}),"\n",(0,o.jsx)(n.p,{children:(0,o.jsx)(n.img,{src:"https://github.com/touying-typ/touying/assets/34951714/aa84192a-4082-495d-9773-b06df32ab8dc",alt:"image"})})]})}function h(e={}){const{wrapper:n}={...(0,i.a)(),...e.components};return n?(0,o.jsx)(n,{...e,children:(0,o.jsx)(l,{...e})}):l(e)}},1151:(e,n,t)=>{t.d(n,{Z:()=>r,a:()=>s});var o=t(7294);const i={},a=o.createContext(i);function s(e){const n=o.useContext(a);return o.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function r(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:s(e.components),o.createElement(a.Provider,{value:n},e.children)}}}]);