// This theme is inspired by the brand guidelines of University of Bristol
// This theme is revised from https://github.com/touying-typ/touying/blob/main/themes/metropolis.typ
// The original theme was written by https://github.com/Enivex
// The code was revised by https://github.com/HPDell

#import "../src/exports.typ": *

#let uob-bullet = `<svg width="522" height="541" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve" overflow="hidden"><g transform="translate(-660 -343)"><g><path d="M817.338 839.899C816.866 801.909 803.983 724.26 713.305 680.188 805.39 709.504 849.694 787.484 854.202 845.649 950.899 864.971 1036.72 910.557 1176.05 862.413L1176.52 862.11C1176.52 862.11 993.179 863.788 916.503 808.216 956.118 809.703 1001.7 800.725 1016.64 778.267 1032.54 754.343 1034.19 729.622 1073.42 728.361 1095.45 727.642 1170.17 733.23 1178 623.285 1154.1 663.727 1128.2 680.435 1089.1 670.443 1064.14 664.087 1018.56 644.926 985.978 683.931 959.085 716.107 930.217 732.842 884.146 727.861 902.579 702.894 1177.26 345.512 1177.26 345.512 1177.26 345.512 825.362 628.521 805.938 645.004 802.204 593.336 817.64 574.373 838.295 551.661 855.222 533.086 884.611 507.921 861.207 454.823 842.31 411.908 844.779 385.954 896.341 344.772 855.25 347.774 792.53 375.462 799.946 451.082 804.454 496.745 772.148 500.712 760.362 507.238 729.732 524.22 725.749 573.633 724.733 612.06 721.271 599.558 676.687 407.532 661 345.407 661 345.435 661 862.11 661 862.11L662.182 862.11C721.903 838.545 771.571 834.945 817.338 839.899" fill="#BF2F38" fill-rule="evenodd" fill-opacity="1"/></g></g></svg>`.text

#let uob-logo = `<?xml version="1.0" encoding="UTF-8"?><svg id="Layer_1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740.08 214.11"><defs><style>.cls-1{fill:#1d1d1b;}.cls-1,.cls-2{stroke-width:0px;}.cls-2{fill:#b01c2e;}</style></defs><path class="cls-1" d="m264.71,133.53c3.16-.13,8.34-.38,11.11-.38,15.53,0,20.83,8.08,20.83,16.92,0,9.85-6.06,14.65-18.18,14.65h-13.77v-31.19Zm-10.48,64.14c0,7.96-2.02,10.36-12.37,10.36h-2.91v2.4h46.22c20.33,0,27.27-14.02,27.27-23.99s-6.94-17.55-18.81-21.09v-.25c8.46-1.52,14.39-8.21,14.39-15.4,0-6.06-2.52-10.36-7.7-14.02-4.55-3.29-14.27-4.93-25.38-4.93-2.4,0-12,.12-18.95.38-3.66.13-12.37.63-15.91.75v2.4h4.42c8.84,0,9.73,3.79,9.73,10.98v52.4Zm10.48-30.56h13.64c14.77,0,22.23,9.98,22.23,19.7s-4.8,20.2-21.47,20.2c-10.61,0-14.4-3.41-14.4-13v-26.9Z"/><path class="cls-1" d="m440.34,134.29v-2.4h-30.69v2.4c7.07.38,9.47,2.27,9.47,9.09v53.79c0,8.21-1.56,10.34-8.79,10.82-9.63-.51-13.72-4.28-20.63-11.19l-9.97-9.98c-5.93-5.94-9.72-9.48-14.39-13.13,10.35-3.03,16.79-10.99,16.79-20.46,0-12.88-10.48-22.48-33.84-22.48-8.21,0-10.74.12-15.91.38-5.18.25-12.88.75-15.91.75v2.4h2.78c7.32,0,9.47,2.27,9.47,10.1v53.16c0,8.46-2.65,10.48-10.1,10.48h-2.15v2.4h35.74v-2.4h-2.91c-7.07,0-10.1-1.9-10.1-9.47v-21.34c2.02.13,3.66.26,6.44.26,3.41,0,5.43-.13,8.59-.26,3.03,2.02,7.46,5.68,13.01,11.24l8.33,8.34c10.92,10.92,15.57,14.38,36.14,13.63h28.63v-2.4c-8.71,0-10.73-2.53-10.73-9.98v-53.54c0-8.46,2.78-10.23,10.73-10.23Zm-93.3,40.79c-2.91,0-4.8.13-7.83-.25v-41.42c2.27-.25,3.91-.25,6.31-.25,19.46,0,24.75,9.1,24.75,20.84,0,15.15-9.21,21.09-23.24,21.09Z"/><path class="cls-1" d="m448.93,191.24c2.66,11.24,11.49,17.8,21.34,17.8,8.46,0,17.42-4.92,17.42-14.9,0-18.19-40.53-23.74-40.53-45.84,0-10.49,9.6-18.31,22.48-18.31,10.6,0,12.75,3.16,17.17,3.16,1.01,0,1.51-.25,2.27-1.26h2.02l2.15,16.04h-2.15c-3.54-9.09-11.62-14.9-20.33-14.9s-14.14,4.79-14.14,11.87c0,17.93,40.54,22.73,40.54,45.96,0,12.38-10.99,21.6-25.76,21.6-6.95,0-15.78-3.41-17.55-3.41-1.14,0-2.03.63-2.53,1.39h-2.15l-2.65-19.19h2.4Z"/><path class="cls-1" d="m545.78,198.81c0,6.82,2.27,9.22,9.97,9.22h4.68v2.4h-39.78v-2.4h4.68c7.7,0,9.97-2.4,9.97-9.22v-62.38h-21.97c-5.05,0-7.32,2.9-9.22,14.01h-2.27l2.02-20.46h2.4c.13.76.63,1.27,1.39,1.52.76.26,1.64.38,2.53.38h60.74c1.77,0,3.66-.38,3.92-1.89h2.4l2.02,20.46h-2.28c-1.89-11.11-4.16-14.01-9.21-14.01h-21.97v62.38Z"/><path class="cls-1" d="m659.83,173.18c0,17.93-9.85,36.11-30.43,36.11s-36.37-16.66-36.37-40.28c0-15.16,8.83-35.86,31.06-35.86,20.84,0,35.73,16.55,35.73,40.03Zm11.87-4.16c0-22.73-20.46-39.02-44.32-39.02-26.89,0-46.22,17.8-46.22,42.93,0,23.62,20.84,39.53,45.59,39.53s44.95-17.93,44.95-43.44Z"/><path class="cls-1" d="m730.37,210.43h-56.44v-2.4h4.17c5.81,0,7.95-1.9,7.95-8.34v-55.94c0-6.69-2.02-9.47-9.97-9.47h-1.77v-2.4h37.25v2.4h-4.68c-8.2,0-10.35.88-10.35,8.71v58.21c0,3.41,1.39,4.68,5.05,4.68h18.56c7.45,0,9.72-2.91,17.68-13.89h2.27l-9.72,18.43Z"/><path class="cls-2" d="m140.49,95.79c-.09-7.35-2.59-22.37-20.17-30.9,17.86,5.67,26.44,20.76,27.32,32.01,18.75,3.74,35.38,12.56,62.39,3.24l.09-.06s-35.54.32-50.41-10.43c7.68.29,16.51-1.45,19.41-5.79,3.09-4.63,3.41-9.41,11.01-9.66,4.27-.14,18.76.94,20.28-20.33-4.63,7.82-9.66,11.06-17.24,9.13-4.84-1.23-13.67-4.94-19.99,2.61-5.21,6.23-10.81,9.46-19.75,8.5C157.02,69.29,210.27.15,210.27.15c0,0-68.22,54.75-71.99,57.94-.72-9.99,2.27-13.66,6.28-18.06,3.28-3.59,8.98-8.46,4.44-18.73-3.67-8.3-3.19-13.33,6.81-21.29-7.97.58-20.12,5.94-18.69,20.57.87,8.84-5.39,9.6-7.68,10.86-5.94,3.28-6.71,12.84-6.9,20.28-.68-2.41-9.32-39.57-12.36-51.59,0,0,0,99.97,0,99.97h.23c11.58-4.56,21.21-5.26,30.08-4.3Z"/><path class="cls-2" d="m209.97,110.37c-45.05,14.77-60.4-16.51-99.8,0-.02,0,0,100.09,0,100.09,42.87-15.93,44.47,13.47,99.8,0,0,0,0-100.09,0-100.09Zm-81.7,51.25c-.23.11-.35.34-.42.47-.42.87-1.69,5.38-2.03,6.64-.34,1.25-.7,1.45-1.4,1.66-.58.18-.66,1.57-.12,1.74,1.64.51,1.28,1.55,1.16,1.8,0,.3-.55,3.18-2.59,5.22-1.06-2.07-1.32-4.15-1.51-4.63-.19-.48-.27-1.11-.22-1.59.05-.48-.11-2.56-.16-3.09-.05-.53.19-1,.41-1.4.41-.75,3.21-6.04,4.47-9.27.47-1.2,3.26-2.39,3.93-2.1.76.32,1.67,1.42,5.72,3.07.1,1.11.34,3.33.92,4.25-.92.38-2.41.53-2.41.53,0,0-3.35-2.71-3.99-3.36-.1-.11-.44-.3-.62-.27-.36.06-.79.18-1.15.34Zm37.97,32.53c-.68-.55-1.77.4-1.21,1.28.68,1.07.63,1.69.63,1.69,0,0-2.17,2.56-5.21,3.04-.29-.29.77-4.27,1.88-6.47.91-1.8,1.3-2.15,2.53-2.73,1.23-.58,6.16-3.07,7.75-4.37,1.59-1.3,2.25-3.24,2.25-3.24,0,0,1.47,1.93,3.4,3.84-.43.7-9.92,6.73-10.36,7.1-.43.36-1.15.28-1.67-.14Zm21.77-5.09c-.36.65-4.61,7.87-5.7,10.45-.58,1.37-1.23,1.09-1.59,1.16-.36.07-1.52.29-1.4,1.57.09.91-.08,1.29-.08,1.29h-7.31c.31-1.06,1.03-2.43,3.87-3.95.91-.48,1.98-1.49,2.8-2.7.43-.63,2.94-5.14,3.38-6.18.35-.84.24-2.12-.19-2.85-.44-.72-1.11-1.98-2.08-2.75-3.24-2.59-5.17-4.64-7.89-9.92-.45-.87.09-1.85-4.61-.6-11.25,2.99-19.43-1.13-19.8-1.45.36-2.15,1.23-3.96-.04-4.9-.69,1.38-1.38,2.35-2.57,3.69-.39.44-.87.29-1.74.22-.87-.07-6.52-.83-7.46-1.05-.39-.09-1.99.4-1.05,2.24.16.31,1.44,2.58,2.79,4.6.72,1.09-.04,1.77.15,2.61.18.81.58,1.09.87,1.01.29-.07,1.49-1.51,2.44-.51.92.97,1.55,3.86,1.74,6.8-.8.07-1.93-.29-2.95-1.08-.95-.74-1.8-2.13-2.82-2.9-1.01-.76-1.48-.73-2.21-1.38-.65-.59-1.3-1.02-1.52-2.83-.22-1.81-2.85-7.7-3.26-8.37-.58-.94.53-2.83,1.01-3.41.43-.51,1.32-.57,2.38-.81,1.58-.36,4.25-1.49,5.15-1.8-3.51-6.65.69-10.71,1.2-11.04,1.18-5.75,3.4-8.91,4.27-10.14,2.08-.44,4.14-.67,5.14-4.85.56-2.35-.51-4.85-1.3-5.65.43,2.17.31,4.57-.87,6.34-1.67,2.5-4.47,2.16-5.05,2.16s-1.15-.11-1.59.36c-.39.41-1.67,1.57-2.53,2.05-.67.38-.56.72-.63,1.33-.07.58-.14,1-.79,1.1-.69.11-1.72-.4-2.26-.4-1.04,0-.41-.56.18-1.36.56-.76.72-.32,1.23-.44.65-.14,1.05-.35,1.56-1.12.77-1.17-1.12-1.37-1.67-.8-.6.64-1.41,1.74-1.92,2.32-.51.58-.97.81-1.23.11-.2-.52-.4-1.52-.43-2.03-1.59-.44-.18-2.17-.18-2.17l4.67-5.7s-1.05-.67-.29-1.91c.4-.65,3.22-4.02,5.21-5.43-.4-1.12-.91-2.24-2.06-3.37,1.77.33,3.22.25,5.98,3.15.71.75,1.49.52,1.23-.22-.29-.82-.76-1.38-1.74-2.57,8.71-2.31,12.92,5.36,13.54,6.23-1.63-.11-2.93.15-3.72.4-.68.22-.63.51.39.63,2.89.34,3.33.46,4.16.71,1.2,1.37,1.85,4.75,1.77,4.89-1.21.07-2.75-.19-4.44.05-1.29.18-.85.76-.34.82,1.93.24,3.77.77,5.21,1.4.48,2.66.36,4.47.36,4.47,0,0-3.38-.36-4.27-.29-.89.07-.45.78.43,1.09.82.29,2.51.92,3.62,1.93-.01.79-.34,2.7-.68,3.67-.33.94-.07,1.77,1.47,2.08,4.21.84,7.8,1.39,14.27,1.26,11.39-.24,15.21,12.89,10.09,19.26-2.4,2.98-2.51,4.73-2.32,5.79.49,2.66,1.93,5.05,4.39,6.5,1.3.77-.02,2.51-.39,3.16Zm12.65-48.33c-3.42,2.89.21,8.43-2.99,12.7-1.74,2.9-6.59,5.89-11.3,2.99,2.75-1.01,5.55-3.32,3.98-7.75-2-5.67-4.66-5.77-7.8-10.6-2.4-3.7-3.72-13.3,5.19-16.42-7.31,4.56-2.97,12.89-.29,15.28-4.66-10.84,2.63-15.86,7.03-15.86,2.41,0,5.38.24,7.15,3.43,2.51,4.54-1.16,7.87-3.09,8.02,3.09-1.45,2.94-4.29,1.88-5.75-1.93-2.66-7.05-1.45-7.97,1.79-1.4,4.94,2.46,7.72,3.84,10.91,1.95-2.75,6.83-3.09,8.91-.14-2.08.1-3.62.63-4.54,1.4Z"/><path class="cls-2" d="m125.44,174s.01-.02.03-.06c0-.05,0-.04-.03.06Z"/><path class="cls-1" d="m310.18,41.83v1.78c-6.27.09-8.52,2.62-8.52,8.61v25.28c0,11.61-7.4,24.06-27.72,24.06-17.88,0-27.06-10.21-27.06-23.6v-27.34c0-5.99-1.69-6.93-8.05-7.02v-1.78h24.06v1.78h-.84c-5.15,0-7.4,1.41-7.4,6.84v26.03c0,12.64,7.4,20.23,21.35,20.23,10.58,0,21.35-4.4,21.35-20.32v-21.82c0-8.99-1.4-10.58-9.18-10.96v-1.78h22Z"/><path class="cls-1" d="m322.49,91.92c0,5.15,1.22,6.37,6.27,6.37v1.78h-18.82v-1.78c4.12,0,6.27-2.25,6.27-5.9v-19.66c0-3.46-.38-4.12-2.81-4.59l-3.18-.65v-1.5l10.77-3.93h1.5v7.3c6.27-3.93,11.52-7.4,16.11-7.4,6.37,0,10.02,4.68,10.02,14.05,0,12.45-.65,14.89-.75,18.54-.09,2.53,1.4,3.75,5.24,3.75h2.06v1.78h-20.13v-1.78c2.71-.09,4.31-.75,5.34-1.78,1.78-1.78,1.97-8.61,1.97-21.07,0-7.49-3.65-9.83-7.4-9.83-3,0-7.58,2.62-12.45,5.99v20.32Z"/><path class="cls-1" d="m373.08,92.95c0,3.28,1.78,5.34,6.74,5.34v1.78h-20.79v-1.78c5.71,0,7.77-1.87,7.77-6.84v-18.82c0-3.65-.47-4.12-2.9-4.59l-4.4-.84v-1.5l12.17-4.21h1.41v31.46Zm-3.84-52.53c2.25,0,4.12,1.59,4.12,3.56s-1.87,3.56-4.12,3.56-4.03-1.59-4.03-3.56,1.78-3.56,4.03-3.56Z"/><path class="cls-1" d="m401.2,100.91l-13.58-31.09c-1.4-3.28-2.62-4.4-4.12-4.68l-2.91-.47v-1.69h19.11v1.69c-5.71.19-7.49.94-5.25,5.34l9.93,23.31,9.55-21.63c1.69-3.84.84-6.55-5.99-7.02v-1.69h16.29v1.69c-3.55.65-5.62,2.71-7.39,6.84l-12.92,29.4h-2.72Z"/><path class="cls-1" d="m432.1,73.85c2.16-8.71,6.84-10.11,9.93-10.11,4.49,0,8.24,4.03,9.27,10.11h-19.2Zm27.06,2.44v-2.15c-3.09-3.09-2.81-12.17-15.45-12.17-11.42,0-18.07,10.11-18.07,20.04,0,10.86,7.11,19.2,16.29,19.2,6.84,0,12.73-4.68,16.67-9.64l-1.03-1.12c-3.56,4.21-7.21,6.09-11.89,6.09-7.4,0-14.23-6.55-14.23-16.29,0-1.22.19-2.53.38-3.93h27.34Z"/><path class="cls-1" d="m477.22,93.23c0,3.84,1.4,5.06,6.09,5.06h3.56v1.78h-22.19v-1.78c4.78-.09,6.28-2.06,6.28-7.02v-21.63l-6.28-2.25v-1.59l10.68-3.75h1.87v9.93h.19c4.68-7.68,5.8-9.46,8.89-9.46,1.13,0,1.41.09,3.18.84.94.37,2.62.75,4.87,1.4l-2.25,5.62c-1.4-.19-3.18-.65-4.96-1.5-1.03-.47-2.15-.94-3.28-.94-1.69,0-2.72,1.12-3.65,2.43-1.22,1.69-2.25,3.28-3,4.68v18.17Z"/><path class="cls-1" d="m500.82,90.61c1.12,5.62,4.68,8.8,8.9,8.8,3.74,0,6.65-2.81,6.65-6.18,0-1.97-.47-3.18-3-5.71-6.65-6.65-14.04-7.3-14.04-15.08,0-6.18,4.87-10.49,11.99-10.49,2.53,0,5.15.56,7.49,1.5l.19,8.52h-1.59c-.66-4.78-3.75-7.77-7.49-7.77-3.09,0-5.71,2.15-5.71,5.24,0,8.24,17.41,9.64,17.41,21.07,0,6.09-5.05,10.67-11.61,10.67-1.78,0-3.09-.28-4.12-.66-1.03-.28-1.78-.56-2.53-.56-.56,0-1.12.38-1.59,1.12h-1.4l-1.03-10.49h1.5Z"/><path class="cls-1" d="m541.39,92.95c0,3.28,1.78,5.34,6.74,5.34v1.78h-20.79v-1.78c5.71,0,7.77-1.87,7.77-6.84v-18.82c0-3.65-.47-4.12-2.9-4.59l-4.4-.84v-1.5l12.17-4.21h1.41v31.46Zm-3.84-52.53c2.25,0,4.12,1.59,4.12,3.56s-1.87,3.56-4.12,3.56-4.02-1.59-4.02-3.56,1.78-3.56,4.02-3.56Z"/><path class="cls-1" d="m574.81,62.99l-1.5,4.12h-11.89v21.82c0,5.9,4.21,7.86,6.18,7.86s3.93-1.59,5.71-4.68l1.5,1.4c-2.25,4.87-5.9,7.68-10.21,7.68-5.53,0-9.46-4.59-9.46-10.86v-23.22h-4.31v-1.5c3.65-1.78,6.84-6.09,8.99-11.89h1.59v9.27h13.39Z"/><path class="cls-1" d="m611.85,73.38c2.81-7.12,1.03-8.52-4.5-8.71v-1.69h15.54v1.69c-3.84.47-5.99,3.09-7.77,7.49l-15.92,39.7c-2.81,6.93-4.96,10.02-8.24,10.02-2.25,0-3.84-1.4-3.84-3.28,0-3.84,5.43-2.9,7.77-5.24,1.03-1.03,2.43-3.46,3.18-5.34l2.81-7.02-14.51-30.81c-1.78-3.84-3.46-5.43-7.4-5.52v-1.69h18.82v1.69c-5.71.09-6.37,1.78-4.49,5.71l10.58,22.85,7.96-19.85Z"/><path class="cls-1" d="m650.94,78.62c0-8.05,5.71-14.42,11.89-14.42,7.87,0,14.42,9.08,14.42,19.76,0,9.36-6.27,14.98-11.8,14.98-8.05,0-14.51-8.99-14.51-20.32Zm-7.02,3.18c0,10.96,8.89,19.38,20.5,19.38s19.85-8.52,19.85-19.57-8.71-19.66-20.13-19.66c-9.74,0-20.22,6.93-20.22,19.85Z"/><path class="cls-1" d="m711.42,67.11h-10.11v25.66c0,4.31,1.69,5.52,6.93,5.52h3.56v1.78h-23.13v-1.78c5.43,0,6.37-1.22,6.37-6.46v-24.72h-6.93v-1.59c2.62-.56,4.87-1.4,6.93-2.53,0-7.77,1.69-13.67,7.21-19.2,4.59-4.59,8.99-6.65,13.29-6.65,5.24,0,9.65,3,9.65,4.4,0,.75-1.78,4.49-2.53,4.49-1.31,0-4.78-4.59-10.96-4.59-6.74,0-10.39,5.34-10.39,14.42v7.12h9.46l.65,4.12Z"/><path class="cls-2" d="m79.33.12v10.79h-12.12s-.48,0-.48,0V.12h-11.59v10.79h-11.59s0-10.79,0-10.79h-11.49v10.79s-.43,0-.43,0h-11.25V.12H0S0,100.54,0,100.09c42.83,14.87,59.58-15.84,99.8,0V.12h-20.47Zm-2.12,33.6c-4.06,8.11-4.44,16.32-3.67,20.47-8.59-2.22-11.49,0-11.49,0,0,0,.19-9.17,15.16-20.47Zm-41.91-9.99c3.41-1.42,3.28-.63,3.09.34-.19.97-.84,2.65,1.06,2.22,5.22-1.17,9.81-4.42,10.24-4.73v6.28c-.76.36-6.19,2.77-10.91,3.09-4.35.29-2.41-4.59-2.41-4.59-.36.24-5.94,3.09-10.53,2.85-5.55-.29-5.79-3.43-5.21-4.1,0,.48.72,4.44,14.68-1.35Zm-17.58,65.04c18.35,5.12,31.09-8.31,43.65-10.04-13.66-.19-21.1,5.46-25.59,5.99-2.32-1.69-4.92-5.87-5.79-10.43-.72-3.77-4.49-4.39-4.49-4.39l-.58-2.85s10.77,1.59,12.7,1.79c2.51,4.01,7.24,4.97,9.56,4.97,0,0,.06-6.79.05-7.19.54-.76,2.46-1.45,2.46-1.45l.1,8.54c5.89,0,10.43-3.77,10.33-7.34-.11-4.06-4.61-7.58-11.78-7.44-7.19.14-9.75,3.67-10.53,4.92-8.55-8.52-4.64-18.93-4.64-18.93,0,0-7.39,4.97-.72,17.58-7-1.88-12.75,1.79-12.65,4.73-.05,2.7,2.08,4.78,6.33,4.93-15.06,2.99-18.44-5.6-11.2-10.24q3.38.58,5.7,1.06c-7.34-7.34-3.78-16.33,2.13-20.18,8.5-1.54,12.75-2.17,12.75-2.17,0,0,4.13-5.94,7.73-8.06,5.21-.48,23.37-3.09,23.37-3.09,0,0-16.97,15.5-.7,31.96,6.69,0,14.65.01,14.65.01,0,0-.34,2.45-.82,4.86-1.45.14-2.22.2-2.8.24-.19,7.53-4.73,12.46-4.73,12.46,0,0,8.5,1.06,14.19,4.54-36.5-6.95-39.49,15.16-68.66,5.21Z"/><path class="cls-2" d="m138.18,136.1s-.48-.24.43-1c.11-.09.29.11.81.12.71,0,1.08-.24,1.67-.95.89-1.08-.97-1.49-1.57-.97-.66.57-1.14,1.15-1.7,1.67,0,0-.95.85.36,1.12Z"/><path class="cls-2" d="m99.8,207.11C67.97,186.23,43.49,217.73,0,195.91,0,195.91,0,210.46,0,210.46c55.33,13.47,56.93-15.93,99.8,0v-3.35Z"/><path class="cls-2" d="m44.73,187.69C17.08,187.89,0,171.16,0,171.16c0,0,0,13.13,0,13.13,39.66,27.07,65.64-3.56,99.8,19.46v-3.53c-8.2-6.38-18.77-12.79-55.08-12.53Z"/><path class="cls-2" d="m70.23,183.83c3.7.75,6.9,1.56,9.69,2.4,7.24,2.38,13.94,5.96,19.87,10.49v-86.35c-10.5-4.4-19.29-5.39-27.39-4.78v46.41l-10.81-10.84-10.81,10.84v-41.95c-14.03,3.8-28.91,7.5-50.8.32C0,111.27,0,133.95,0,153.71c0,0,11.39,24.23,42.15,26.52,11.72.87,20.85,2.13,28.08,3.6"/></svg>`.text

#let multicolumns(columns: auto, alignment: top, gutter: 1em, ..bodies) = {
  let bodies = bodies.pos()
  if bodies.len() == 1 {
    return bodies.first()
  }
  let columns = if columns == auto {
    (1fr,) * bodies.len()
  } else {
    columns
  }
  grid(columns: columns, gutter: gutter, align: alignment, ..bodies)
}

#let _typst-builtin-align = align

/// Default slide function for the presentation.
///
/// - `title` is the title of the slide. Default is `auto`.
///
/// - `config` is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - `repeat` is the number of subslides. Default is `auto`，which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - `setting` is the setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - `composer` is the composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]] will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  title: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }
  // restore typst builtin align function
  let align = _typst-builtin-align
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.primary, inset: (x: 2em))
    set align(horizon)
    set text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.2em)
    if title != auto {
      utils.fit-to-width.with(grow: false, 100%, title)
    } else {
      utils.call-or-display(self, self.store.header)
    }
  }
  let footer(self) = {
    set align(bottom)
    set text(size: 0.8em)
    block(height: 1.5em, width: 100%, stroke: (top: self.colors.primary + 2pt), pad(
      y: .4em,
      x: 2em,
      components.left-and-right(
        text(fill: self.colors.neutral-darkest, utils.call-or-display(self, self.store.footer)),
        text(fill: self.colors.neutral-darkest, utils.call-or-display(self, self.store.footer-right)),
      ),
    ))
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      header: header,
      footer: footer,
    ),
  )
  let new-setting = body => {
    show: align.with(self.store.align)
    set text(fill: self.colors.neutral-darkest)
    show heading.where(level: self.slide-level + 1): it => {
      stack(
        dir: ltr, spacing: .4em,
        image.decode(uob-bullet, height: .8em),
        text(fill: self.colors.primary, it.body)
      )
    }
    set enum(numbering: (nums) => {
      text(fill: self.colors.primary, weight: "bold", str(nums) + ".")
    })
    set list(marker: (level) => {
      text(fill: self.colors.primary, weight: "bold", sym.triangle.r.filled)
    })
    set table(stroke: self.colors.primary)
    show: setting
    body
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: multicolumns, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: metropolis-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.city,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle], extra: [Extra information])
/// ```
///
/// - `extra` is the extra information you want to display on the title slide.
#let title-slide(
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set text(fill: self.colors.neutral-darkest)
    set align(horizon)
    grid(
      rows: (auto, 1fr),
      pad(y: 2em, x: 2em, image.decode(uob-logo, height: 2.4em)),
      block(width: 100%, height: 100%, {
        set align(bottom)
        grid(
          columns: (1fr, auto),
          block(
            width: 100%,
            height: 8cm,
            inset: (x: 2em, top: 4em),
            {
              set align(left + horizon)
              set text(16pt)
              stack(
                dir: ttb,
                spacing: 8pt,
                self.info.date.display(self.info.datetime-format),
                self.info.institution
              )
            }
          ),
          polygon(
            stroke: none,
            fill: gray.transparentize(60%),
            (0pt, 0pt),
            (2cm, -8cm),
            (14cm, -8cm),
            (14cm, 0pt)
          )
        )
        place(top + left, float: true, {
          set text(fill: white)
          place(top + left, polygon(
            fill: self.colors.primary.transparentize(10%),
            stroke: none,
            (0cm, 0cm),
            (0cm, 8cm),
            (22cm, 8cm),
            (24cm, 0cm)
          ))
          place(top + left, float: true, grid(
            rows: (4cm, 4cm),
            columns: (24cm),
            block(inset: (x: 2em, y: 1em), width: 100%, height: 100%, {
              set align(bottom + left)
              set text(size: 32pt, weight: "bold")
              info.title
            }),
            block(inset: (left: 2em, right: 8em, y: 1em), width: 100%, height: 100%, {
              set align(top + left)
              set text(size: 24pt)
              info.subtitle
            })
          ))
        })
      })
    )
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: self.colors.neutral-lightest, 
      margin: 0em
    ),
  )
  touying-slide(self: self, body)
})

#let outline-slide(title: [Outline], column: 2, marker: auto, ..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let header = {
    set align(center + bottom)
    block(
      fill: self.colors.neutral-lightest,
      outset: (x: 2.4em, y: .8em),
      stroke: (bottom: self.colors.primary + 3.2pt),
      text(self.colors.primary, weight: "bold", size: 1.6em, title)
    )
  }
  let body = {
    set align(horizon)
    show outline.entry: it => {
      let mark = if ( marker == auto ) {
        image.decode(uob-bullet, height: .8em)
      } else if type(marker) == image {
        set image(height: .8em)
        image
      } else if type(marker) == symbol {
        text(fill: self.colors.primary, marker)
      }
      block(stack(dir: ltr, spacing: .8em, mark, it.body), below: 0pt)
    }
    show: pad.with(x: 1.6em)
    columns(column, outline(title: none, indent: 1em, depth: 1))
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      margin: (top: 4.8em, bottom: 1.6em),
      fill: self.colors.neutral-lightest
    )
  )
  touying-slide(self: self, body)
})

/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - `level` is the level of the heading.
///
/// - `numbered` is whether the heading is numbered.
///
/// - `title` is the title of the section. It will be pass by touying automatically.
#let new-section-slide(level: 1, numbered: true, title) = touying-slide-wrapper(self => {
  let header = {
    components.progress-bar(height: 8pt, self.colors.primary, self.colors.primary.lighten(40%))
  }
  let footer = {
    set align(bottom)
    set text(size: 0.8em, fill: self.colors.neutral-lightest)
    block(height: 1.5em, width: 100%, fill: self.colors.primary, pad(
      y: .4em,
      x: 2em,
      components.left-and-right(
        text(utils.call-or-display(self, self.store.footer)),
        text(utils.call-or-display(self, self.store.footer-right)),
      ),
    ))
  }
  let body = {
    set align(horizon + center)
    show: pad.with(20%)
    set text(size: 1.5em, fill: self.colors.neutral-lightest, weight: "bold")
    block(
      // outset: (right: 2pt, bottom: 2pt),
      fill: self.colors.neutral-light,
      radius: 8pt,
      move(dx: -4pt, dy: -4pt, block(
        width: 100%,
        fill: self.colors.primary,
        inset: (x: 1em, y: .8em),
        radius: 8pt,
        utils.display-current-heading(level: level, numbered: numbered)
      ))
    )
  }
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      header: header,
      footer: footer,
      margin: 0em,
    ),
  )
  touying-slide(self: self, body)
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - `align` is the alignment of the content. Default is `horizon + center`.
#let focus-slide(align: horizon + center, body) = touying-slide-wrapper(self => {
  let _align = align
  let align = _typst-builtin-align
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest, margin: 2em),
  )
  set text(fill: self.colors.primary, size: 1.5em)
  touying-slide(self: self, align(_align, body))
})


/// Touying metropolis theme.
///
/// Example:
///
/// ```typst
/// #show: metropolis-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// Consider using:
///
/// ```typst
/// #set text(font: "Fira Sans", weight: "light", size: 20pt)`
/// #show math.equation: set text(font: "Fira Math")
/// #set strong(delta: 100)
/// #set par(justify: true)
/// ```
///
/// - `aspect-ratio` is the aspect ratio of the slides. Default is `16-9`.
///
/// - `align` is the alignment of the content. Default is `horizon`.
///
/// - `header` is the header of the slide. Default is `self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level)`.
///
/// - `header-right` is the right part of the header. Default is `self => self.info.logo`.
///
/// - `footer` is the footer of the slide. Default is `none`.
///
/// - `footer-right` is the right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - `footer-progress` is whether to show the progress bar in the footer. Default is `true`.
///
/// ----------------------------------------
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   primary: rgb("#eb811b"),
///   primary-light: rgb("#d6c6b7"),
///   secondary: rgb("#23373b"),
///   neutral-lightest: rgb("#fafafa"),
///   neutral-dark: rgb("#23373b"),
///   neutral-darkest: rgb("#23373b"),
/// )
/// ```
#let uobristol-theme(
  aspect-ratio: "16-9",
  align: horizon,
  header: self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level),
  header-right: self => self.info.logo,
  footer: none,
  footer-right: context utils.slide-counter.display(),
  footer-progress: true,
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 30%,
      footer-descent: 30%,
      margin: (top: 3em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 20pt, font: "Lato")
        show highlight: body => text(fill: self.colors.primary, strong(body.body))
        body
      },
      alert: utils.alert-with-primary-color
    ),
    config-colors(
      neutral-lightest: rgb("#fafafa"),
      primary: rgb("#ab1f2d"),
      secondary: rgb("#ea6719")
    ),
    // save the variables for later use
    config-store(
      align: align,
      header: header,
      header-right: header-right,
      footer: footer,
      footer-right: footer-right,
      footer-progress: footer-progress,
    ),
    config-info(
      datetime-format: "[day] [month repr:short] [year]",
    ),
    ..args,
  )
  body
}
