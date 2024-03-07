"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[7545],{7512:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>d,contentTitle:()=>o,default:()=>a,frontMatter:()=>r,metadata:()=>l,toc:()=>c});var i=s(5893),t=s(1151);const r={sidebar_position:11},o="Changelog",l={id:"changelog",title:"Changelog",description:"v0.2.1",source:"@site/versioned_docs/version-0.2.x/changelog.md",sourceDirName:".",slug:"/changelog",permalink:"/touying/docs/0.2.x/changelog",draft:!1,unlisted:!1,editUrl:"https://github.com/touying-typ/touying/tree/main/docs/versioned_docs/version-0.2.x/changelog.md",tags:[],version:"0.2.x",sidebarPosition:11,frontMatter:{sidebar_position:11},sidebar:"tutorialSidebar",previous:{title:"Typst Preview",permalink:"/touying/docs/0.2.x/external/typst-preview"}},d={},c=[{value:"v0.2.1",id:"v021",level:2},{value:"Features",id:"features",level:3},{value:"Fix",id:"fix",level:3},{value:"v0.2.0",id:"v020",level:2}];function h(e){const n={a:"a",code:"code",h1:"h1",h2:"h2",h3:"h3",li:"li",strong:"strong",ul:"ul",...(0,t.a)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(n.h1,{id:"changelog",children:"Changelog"}),"\n",(0,i.jsx)(n.h2,{id:"v021",children:"v0.2.1"}),"\n",(0,i.jsx)(n.h3,{id:"features",children:"Features"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Touying-reducer"}),": support cetz and fletcher animation"]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"university theme"}),": add university theme"]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"fix",children:"Fix"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:"fix footer progress in metropolis theme"}),"\n",(0,i.jsx)(n.li,{children:"fix some bugs in simple and dewdrop themes"}),"\n",(0,i.jsx)(n.li,{children:"fix bug that outline does not display more than 4 sections"}),"\n"]}),"\n",(0,i.jsx)(n.h2,{id:"v020",children:"v0.2.0"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Object-oriented programming:"})," Singleton ",(0,i.jsx)(n.code,{children:"s"}),", binding methods ",(0,i.jsx)(n.code,{children:"utils.methods(s)"})," and ",(0,i.jsx)(n.code,{children:"(self: obj, ..) => {..}"})," methods."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Page arguments management:"})," Instead of using ",(0,i.jsx)(n.code,{children:"#set page(..)"}),", you should use ",(0,i.jsx)(n.code,{children:"self.page-args"})," to retrieve or set page parameters, thereby avoiding unnecessary creation of new pages."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsxs)(n.strong,{children:[(0,i.jsx)(n.code,{children:"#pause"})," for sequence content:"]})," You can use #pause at the outermost level of a slide, including inline and list."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsxs)(n.strong,{children:[(0,i.jsx)(n.code,{children:"#pause"})," for layout functions:"]})," You can use the ",(0,i.jsx)(n.code,{children:"composer"})," parameter to add yourself layout function like ",(0,i.jsx)(n.code,{children:"utils.side-by-side"}),", and simply use multiple pos parameters like ",(0,i.jsx)(n.code,{children:"#slide[..][..]"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsxs)(n.strong,{children:[(0,i.jsx)(n.code,{children:"#meanwhile"})," for synchronous display:"]})," Provide a ",(0,i.jsx)(n.code,{children:"#meanwhile"})," for resetting subslides counter."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsxs)(n.strong,{children:[(0,i.jsx)(n.code,{children:"#pause"})," and ",(0,i.jsx)(n.code,{children:"#meanwhile"})," for math equation:"]})," Provide a ",(0,i.jsx)(n.code,{children:'#touying-equation("x + y pause + z")'})," for math equation animations."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Slides:"})," Create simple slides using standard headings."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsxs)(n.strong,{children:["Callback-style ",(0,i.jsx)(n.code,{children:"uncover"}),", ",(0,i.jsx)(n.code,{children:"only"})," and ",(0,i.jsx)(n.code,{children:"alternatives"}),":"]})," Based on the concise syntax provided by Polylux, allow precise control of the timing for displaying content.","\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:["You should manually control the number of subslides using the ",(0,i.jsx)(n.code,{children:"repeat"})," parameter."]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Transparent cover:"})," Enable transparent cover using oop syntax like ",(0,i.jsx)(n.code,{children:"#let s = (s.methods.enable-transparent-cover)(self: s)"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Handout mode:"})," enable handout mode by ",(0,i.jsx)(n.code,{children:"#let s = (s.methods.enable-handout-mode)(self: s)"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Fit-to-width and fit-to-height:"})," Fit-to-width for title in header and fit-to-height for image.","\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:(0,i.jsx)(n.code,{children:"utils.fit-to-width(grow: true, shrink: true, width, body)"})}),"\n",(0,i.jsx)(n.li,{children:(0,i.jsx)(n.code,{children:"utils.fit-to-height(width: none, prescale-width: none, grow: true, shrink: true, height, body)"})}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Slides counter:"})," ",(0,i.jsx)(n.code,{children:'states.slide-counter.display() + " / " + states.last-slide-number'})," and ",(0,i.jsx)(n.code,{children:"states.touying-progress(ratio => ..)"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Appendix:"})," Freeze the ",(0,i.jsx)(n.code,{children:"last-slide-number"})," to prevent the slide number from increasing further."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Sections:"})," Touying's built-in section support can be used to display the current section title and show progress.","\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.code,{children:"section"})," and ",(0,i.jsx)(n.code,{children:"subsection"})," parameter in ",(0,i.jsx)(n.code,{children:"#slide"})," to register a new section or subsection."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.code,{children:"states.current-section-title"})," to get the current section."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.code,{children:"states.touying-outline"})," or ",(0,i.jsx)(n.code,{children:"s.methods.touying-outline"})," to display a outline of sections."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.code,{children:"states.touying-final-sections(sections => ..)"})," for custom outline display."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.code,{children:"states.touying-progress-with-sections((current-sections: .., final-sections: .., current-slide-number: .., last-slide-number: ..) => ..)"})," for powerful progress display."]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Navigation bar"}),": Navigation bar like ",(0,i.jsx)(n.a,{href:"https://github.com/zbowang/BeamerTheme",children:"here"})," by ",(0,i.jsx)(n.code,{children:"states.touying-progress-with-sections(..)"}),", in ",(0,i.jsx)(n.code,{children:"dewdrop"})," theme."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Pdfpc:"})," pdfpc support and export ",(0,i.jsx)(n.code,{children:".pdfpc"})," file without external tool by ",(0,i.jsx)(n.code,{children:"typst query"})," command simply."]}),"\n"]})]})}function a(e={}){const{wrapper:n}={...(0,t.a)(),...e.components};return n?(0,i.jsx)(n,{...e,children:(0,i.jsx)(h,{...e})}):h(e)}},1151:(e,n,s)=>{s.d(n,{Z:()=>l,a:()=>o});var i=s(7294);const t={},r=i.createContext(t);function o(e){const n=i.useContext(r);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function l(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:o(e.components),i.createElement(r.Provider,{value:n},e.children)}}}]);