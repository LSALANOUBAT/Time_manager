(function(){var e={4140:function(e){function t(e){return Promise.resolve().then((function(){var t=new Error("Cannot find module '"+e+"'");throw t.code="MODULE_NOT_FOUND",t}))}t.keys=function(){return[]},t.resolve=t,t.id=4140,e.exports=t},5512:function(e,t,r){"use strict";var a=r(5130),s=r(8061),n=r(6768);const o={id:"app"};function i(e,t,r,a,s,i){const l=(0,n.g2)("UserManager"),u=(0,n.g2)("WorkingTimes"),c=(0,n.g2)("WorkingTime"),d=(0,n.g2)("ClockManager"),h=(0,n.g2)("ChartManager");return(0,n.uX)(),(0,n.CE)("div",o,[(0,n.Lk)("header",null,[t[1]||(t[1]=(0,n.Lk)("h1",null,"Time Manager Application",-1)),(0,n.Lk)("button",{onClick:t[0]||(t[0]=(...e)=>i.readPageContent&&i.readPageContent(...e))},"Lire cette page")]),(0,n.Lk)("main",null,[(0,n.bF)(l),(0,n.bF)(u),(0,n.bF)(c),(0,n.bF)(d),(0,n.bF)(h)])])}var l=r(4232);const u={class:"user-component"},c={key:0},d={key:1,class:"error-message"},h={key:2,class:"user-table"},m=["onClick"],g=["onClick"];function k(e,t,r,s,o,i){return(0,n.uX)(),(0,n.CE)("div",u,[t[12]||(t[12]=(0,n.Lk)("h2",null,"User Management",-1)),(0,n.Lk)("form",{onSubmit:t[2]||(t[2]=(0,a.D$)(((...e)=>i.createUser&&i.createUser(...e)),["prevent"]))},[(0,n.bo)((0,n.Lk)("input",{"onUpdate:modelValue":t[0]||(t[0]=e=>o.username=e),placeholder:"Username",required:""},null,512),[[a.Jo,o.username]]),(0,n.bo)((0,n.Lk)("input",{"onUpdate:modelValue":t[1]||(t[1]=e=>o.email=e),type:"email",placeholder:"Email",required:""},null,512),[[a.Jo,o.email]]),t[7]||(t[7]=(0,n.Lk)("button",{type:"submit"},"Create User",-1))],32),(0,n.bo)((0,n.Lk)("input",{"onUpdate:modelValue":t[3]||(t[3]=e=>o.userId=e),placeholder:"User ID"},null,512),[[a.Jo,o.userId]]),(0,n.Lk)("button",{onClick:t[4]||(t[4]=(...e)=>i.getUser&&i.getUser(...e))},"Get User"),(0,n.Lk)("button",{onClick:t[5]||(t[5]=(...e)=>i.updateUser&&i.updateUser(...e))},"Update User"),(0,n.Lk)("button",{onClick:t[6]||(t[6]=(...e)=>i.deleteUser&&i.deleteUser(...e))},"Delete User"),o.userData?((0,n.uX)(),(0,n.CE)("div",c,[t[10]||(t[10]=(0,n.Lk)("h3",null,"User Details:",-1)),(0,n.Lk)("p",null,[t[8]||(t[8]=(0,n.Lk)("strong",null,"Username:",-1)),(0,n.eW)(" "+(0,l.v_)(o.userData.username),1)]),(0,n.Lk)("p",null,[t[9]||(t[9]=(0,n.Lk)("strong",null,"Email:",-1)),(0,n.eW)(" "+(0,l.v_)(o.userData.email),1)])])):(0,n.Q3)("",!0),o.errorMessage?((0,n.uX)(),(0,n.CE)("div",d,[(0,n.Lk)("p",null,"Error: "+(0,l.v_)(o.errorMessage),1)])):(0,n.Q3)("",!0),t[13]||(t[13]=(0,n.Lk)("h3",null,"Liste des utilisateurs :",-1)),o.users.length?((0,n.uX)(),(0,n.CE)("table",h,[t[11]||(t[11]=(0,n.Lk)("thead",null,[(0,n.Lk)("tr",null,[(0,n.Lk)("th",null,"ID"),(0,n.Lk)("th",null,"Username"),(0,n.Lk)("th",null,"Email"),(0,n.Lk)("th",null,"Actions")])],-1)),(0,n.Lk)("tbody",null,[((0,n.uX)(!0),(0,n.CE)(n.FK,null,(0,n.pI)(o.users,(e=>((0,n.uX)(),(0,n.CE)("tr",{key:e.id},[(0,n.Lk)("td",null,(0,l.v_)(e.id),1),(0,n.Lk)("td",null,(0,l.v_)(e.username),1),(0,n.Lk)("td",null,(0,l.v_)(e.email),1),(0,n.Lk)("td",null,[(0,n.Lk)("button",{onClick:t=>i.selectUser(e)},"Sélectionner",8,m),(0,n.Lk)("button",{onClick:t=>i.deleteUser(e.id)},"Supprimer",8,g)])])))),128))])])):(0,n.Q3)("",!0)])}r(4114);const p="http://localhost:4000/api";var f={data(){return{username:"",email:"",userId:"",userData:null,users:[],errorMessage:null}},methods:{async createUser(){try{const e=await fetch(`${p}/users`,{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({user:{username:this.username,email:this.email}})}),t=await e.json();console.log("User created:",t),this.users.push(t),this.clearFields()}catch(e){console.error("Failed to create user:",e),this.errorMessage="Failed to create user. Please try again."}},async getUser(){try{const e=await fetch(`${p}/users/${this.userId}`);if(!e.ok)throw new Error(`Server error: ${e.status}`);const t=await e.json();console.log("User data:",t),this.userData=t}catch(e){console.error("Failed to fetch user data:",e),this.errorMessage="Failed to fetch user data. Please check the User ID."}},async updateUser(){try{const e=await fetch(`${p}/users/${this.userId}`,{method:"PUT",headers:{"Content-Type":"application/json"},body:JSON.stringify({user:{username:this.username,email:this.email}})}),t=await e.json();console.log("User updated:",t);const r=this.users.findIndex((e=>e.id===t.id));-1!==r&&this.$set(this.users,r,t),this.clearFields()}catch(e){console.error("Failed to update user:",e),this.errorMessage="Failed to update user. Please try again."}},async deleteUser(e){try{const t=await fetch(`${p}/users/${e}`,{method:"DELETE"});if(!t.ok)throw new Error(`Server error: ${t.status}`);console.log("User deleted successfully"),this.users=this.users.filter((t=>t.id!==e)),this.clearFields()}catch(t){console.error("Failed to delete user:",t),this.errorMessage="Failed to delete user. Please check the User ID."}},selectUser(e){this.userId=e.id,this.username=e.username,this.email=e.email},async fetchUsers(){try{const e=await fetch(`${p}/users`),t=await e.json();this.users=t}catch(e){console.error("Failed to fetch users:",e),this.errorMessage="Failed to load users."}},clearFields(){this.username="",this.email="",this.userId="",this.userData=null,this.errorMessage=null}},mounted(){this.fetchUsers()}},v=r(1241);const b=(0,v.A)(f,[["render",k]]);var C=b;const y={class:"working-times"},w={key:0,class:"error-message"};function I(e,t,r,s,o,i){return(0,n.uX)(),(0,n.CE)("div",y,[t[2]||(t[2]=(0,n.Lk)("h2",null,"Working Times",-1)),(0,n.bo)((0,n.Lk)("input",{"onUpdate:modelValue":t[0]||(t[0]=e=>o.userId=e),placeholder:"Enter User ID",onInput:t[1]||(t[1]=(...e)=>i.getWorkingTimes&&i.getWorkingTimes(...e))},null,544),[[a.Jo,o.userId]]),(0,n.Lk)("ul",null,[((0,n.uX)(!0),(0,n.CE)(n.FK,null,(0,n.pI)(o.workingTimes,(e=>((0,n.uX)(),(0,n.CE)("li",{key:e.id},(0,l.v_)(e.start)+" - "+(0,l.v_)(e.end),1)))),128))]),o.errorMessage?((0,n.uX)(),(0,n.CE)("div",w,[(0,n.Lk)("p",null,"Error: "+(0,l.v_)(o.errorMessage),1)])):(0,n.Q3)("",!0)])}var D={data(){return{userId:"",workingTimes:[],errorMessage:null}},methods:{async getWorkingTimes(){const e="http://localhost:4000/api";if(!this.userId)return this.errorMessage="Please enter a valid User ID",void(this.workingTimes=[]);try{const t=await fetch(`${e}/workingtime/${this.userId}`);if(!t.ok)throw new Error(`Server error: ${t.status}`);const r=await t.json();this.workingTimes=r,this.errorMessage=null}catch(t){console.error("Failed to fetch working times:",t),this.errorMessage="Failed to fetch working times. Please try again.",this.workingTimes=[]}}}};const L=(0,v.A)(D,[["render",I],["__scopeId","data-v-8900efac"]]);var U=L;const T={class:"working-time"};function E(e,t,r,s,o,i){return(0,n.uX)(),(0,n.CE)("div",T,[t[10]||(t[10]=(0,n.Lk)("h2",null,"Manage Working Time",-1)),(0,n.Lk)("form",{onSubmit:t[3]||(t[3]=(0,a.D$)(((...e)=>i.createWorkingTime&&i.createWorkingTime(...e)),["prevent"]))},[t[6]||(t[6]=(0,n.Lk)("label",{for:"userId"},"User ID:",-1)),(0,n.bo)((0,n.Lk)("input",{type:"text","onUpdate:modelValue":t[0]||(t[0]=e=>o.userId=e),id:"userId",placeholder:"User ID",required:""},null,512),[[a.Jo,o.userId]]),t[7]||(t[7]=(0,n.Lk)("label",{for:"start"},"Start Time:",-1)),(0,n.bo)((0,n.Lk)("input",{type:"datetime-local","onUpdate:modelValue":t[1]||(t[1]=e=>o.start=e),id:"start",placeholder:"Start Time",required:""},null,512),[[a.Jo,o.start]]),t[8]||(t[8]=(0,n.Lk)("label",{for:"end"},"End Time:",-1)),(0,n.bo)((0,n.Lk)("input",{type:"datetime-local","onUpdate:modelValue":t[2]||(t[2]=e=>o.end=e),id:"end",placeholder:"End Time",required:""},null,512),[[a.Jo,o.end]]),t[9]||(t[9]=(0,n.Lk)("button",{type:"submit"},"Create Working Time",-1))],32),(0,n.Lk)("button",{onClick:t[4]||(t[4]=(...e)=>i.updateWorkingTime&&i.updateWorkingTime(...e))},"Update Working Time"),(0,n.Lk)("button",{onClick:t[5]||(t[5]=(...e)=>i.deleteWorkingTime&&i.deleteWorkingTime(...e))},"Delete Working Time")])}const S="http://localhost:4000/api";var F={data(){return{userId:null,workingTimeId:null,start:"",end:""}},methods:{formatToISOString(e){return new Date(e).toISOString()},async createWorkingTime(){if(!this.userId)return void console.error("User ID is required to create working time");const e=this.formatToISOString(this.start),t=this.formatToISOString(this.end),r=await fetch(`${S}/${this.userId}`,{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({workingtime:{user_id:this.userId,start:e,end:t}})}),a=await r.json();console.log("Working time created:",a)},async updateWorkingTime(){if(!this.userId||!this.workingTimeId)return void console.error("User ID and Working Time ID are required to update working time");const e=this.formatToISOString(this.start),t=this.formatToISOString(this.end),r=await fetch(`${S}/workingtime/${this.workingTimeId}`,{method:"PUT",headers:{"Content-Type":"application/json"},body:JSON.stringify({workingtime:{user_id:this.userId,start:e,end:t}})}),a=await r.json();console.log("Working time updated:",a)},async deleteWorkingTime(){if(!this.userId||!this.workingTimeId)return void console.error("User ID and Working Time ID are required to delete working time");const e=await fetch(`${S}/workingtime/${this.userId}/${this.workingTimeId}`,{method:"DELETE",headers:{"Content-Type":"application/json"}}),t=await e.json();console.log("Working time deleted:",t)}}};const M=(0,v.A)(F,[["render",E]]);var O=M;const W={class:"clock-manager"},_={key:0,class:"error-message"};function $(e,t,r,s,o,i){return(0,n.uX)(),(0,n.CE)("div",W,[t[2]||(t[2]=(0,n.Lk)("h2",null,"Clock Manager",-1)),(0,n.bo)((0,n.Lk)("input",{"onUpdate:modelValue":t[0]||(t[0]=e=>o.userId=e),placeholder:"Enter User ID"},null,512),[[a.Jo,o.userId]]),(0,n.Lk)("p",null,"Status: "+(0,l.v_)(o.clockIn?"Clocked In":"Clocked Out"),1),(0,n.Lk)("button",{onClick:t[1]||(t[1]=(...e)=>i.clock&&i.clock(...e))},(0,l.v_)(o.clockIn?"Clock Out":"Clock In"),1),o.errorMessage?((0,n.uX)(),(0,n.CE)("div",_,[(0,n.Lk)("p",null,"Error: "+(0,l.v_)(o.errorMessage),1)])):(0,n.Q3)("",!0)])}const j="http://localhost:4000/api";var P={data(){return{userId:"",clockIn:!1,errorMessage:null}},methods:{async clock(){if(this.userId)try{const e=await fetch(`${j}/clocks/${this.userId}`,{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({clock:{status:!this.clockIn,time:(new Date).toISOString()}})});if(!e.ok)throw new Error(`Server error: ${e.status}`);const t=await e.json();this.clockIn=!this.clockIn,console.log("Clock status changed:",t),this.errorMessage=null}catch(e){console.error("Failed to change clock status:",e),this.errorMessage="Failed to change clock status. Please try again."}else this.errorMessage="Please enter a valid User ID"}}};const X=(0,v.A)(P,[["render",$],["__scopeId","data-v-31b15def"]]);var A=X;const N={class:"chart-manager"},x={class:"user-selector"},J=["value"],q={key:3,class:"error-message"};function V(e,t,r,s,o,i){const u=(0,n.g2)("line-chart"),c=(0,n.g2)("bar-chart"),d=(0,n.g2)("pie-chart");return(0,n.uX)(),(0,n.CE)("div",N,[t[4]||(t[4]=(0,n.Lk)("h2",null,"Charts Overview",-1)),(0,n.Lk)("div",x,[t[3]||(t[3]=(0,n.Lk)("label",{for:"user-select"},"Select User: ",-1)),(0,n.bo)((0,n.Lk)("select",{id:"user-select","onUpdate:modelValue":t[0]||(t[0]=e=>o.selectedUserId=e),onChange:t[1]||(t[1]=(...e)=>i.fetchUserData&&i.fetchUserData(...e))},[t[2]||(t[2]=(0,n.Lk)("option",{value:""},"--Select a user--",-1)),((0,n.uX)(!0),(0,n.CE)(n.FK,null,(0,n.pI)(o.users,(e=>((0,n.uX)(),(0,n.CE)("option",{key:e.id,value:e.id},(0,l.v_)(e.username),9,J)))),128))],544),[[a.u1,o.selectedUserId]])]),o.lineChartData.datasets.length?((0,n.uX)(),(0,n.Wv)(u,{key:0,"chart-data":o.lineChartData},null,8,["chart-data"])):(0,n.Q3)("",!0),o.barChartData.datasets.length?((0,n.uX)(),(0,n.Wv)(c,{key:1,"chart-data":o.barChartData},null,8,["chart-data"])):(0,n.Q3)("",!0),o.pieChartData.datasets.length?((0,n.uX)(),(0,n.Wv)(d,{key:2,"chart-data":o.pieChartData},null,8,["chart-data"])):(0,n.Q3)("",!0),o.errorMessage?((0,n.uX)(),(0,n.CE)("div",q,[(0,n.Lk)("p",null,"Error: "+(0,l.v_)(o.errorMessage),1)])):(0,n.Q3)("",!0)])}var Q=r(1010),B=r(6912);const R="http://localhost:4000/api";B.t1.register(B.hE,B.m_,B.s$,B.No,B.E8,B.FN,B.kc,B.PP,B.Bs);var H={components:{LineChart:{extends:Q.N1,props:["chartData"],mounted(){this.renderChart(this.chartData,{responsive:!0,maintainAspectRatio:!1})}},BarChart:{extends:Q.yP,props:["chartData"],mounted(){this.renderChart(this.chartData,{responsive:!0,maintainAspectRatio:!1})}},PieChart:{extends:Q.Fq,props:["chartData"],mounted(){this.renderChart(this.chartData,{responsive:!0,maintainAspectRatio:!1})}}},data(){return{users:[],selectedUserId:"",lineChartData:{labels:[],datasets:[]},barChartData:{labels:[],datasets:[]},pieChartData:{labels:[],datasets:[]},errorMessage:null}},async created(){try{const e=await fetch(`${R}/users`);if(!e.ok)throw new Error(`Server error: ${e.status}`);this.users=await e.json()}catch(e){console.error("Failed to fetch users:",e),this.errorMessage="Failed to fetch users. Please try again."}},methods:{async fetchUserData(){if(this.selectedUserId)try{const e=await fetch(`${R}/workingtime/${this.selectedUserId}`);if(!e.ok)throw new Error(`Server error: ${e.status}`);const t=await e.json();t&&t.length>0?(this.transformChartData(t),this.errorMessage=null):(this.errorMessage="No working time data available for this user.",this.clearChartData())}catch(e){console.error("Failed to fetch working time data:",e),this.errorMessage="Failed to fetch chart data. Please try again.",this.clearChartData()}else this.clearChartData()},clearChartData(){this.lineChartData={labels:[],datasets:[]},this.barChartData={labels:[],datasets:[]},this.pieChartData={labels:[],datasets:[]}},transformChartData(e){const t=e.sort(((e,t)=>new Date(e.start_time)-new Date(t.start_time))),r=t.map((e=>new Date(e.start_time).toLocaleDateString())),a=t.map((e=>this.calculateDuration(e.start_time,e.end_time)));this.lineChartData={labels:r,datasets:[{label:"Working Time Duration (Hours)",data:a,borderColor:"rgba(75, 192, 192, 1)",backgroundColor:"rgba(75, 192, 192, 0.2)",fill:!1}]},this.barChartData={labels:r,datasets:[{label:"Working Time Duration (Hours)",data:a,backgroundColor:"rgba(153, 102, 255, 0.6)",borderColor:"rgba(153, 102, 255, 1)",borderWidth:1}]},this.pieChartData={labels:r,datasets:[{label:"Working Time Distribution",data:a,backgroundColor:["#FF6384","#36A2EB","#FFCE56","#4BC0C0","#9966FF","#FF9F40"]}]}},calculateDuration(e,t){const r=new Date(e),a=new Date(t);return(a-r)/36e5}}};const K=(0,v.A)(H,[["render",V],["__scopeId","data-v-62c71d54"]]);var G=K,z={name:"App",components:{UserManager:C,WorkingTimes:U,WorkingTime:O,ClockManager:A,ChartManager:G},methods:{readPageContent(){const e=document.body.innerText;if("speechSynthesis"in window){const t=new SpeechSynthesisUtterance(e);t.lang="fr-FR",window.speechSynthesis.speak(t)}else alert("Votre navigateur ne supporte pas la synthèse vocale.")}}};const Y=(0,v.A)(z,[["render",i]]);var Z=Y,ee=r(1387);const te=[{path:"/",name:"Home",component:Z}],re=(0,ee.aE)({history:(0,ee.LA)("/"),routes:te});var ae=re;r(9326),r(202),r(1152),r(9256);(0,a.Ef)(Z).use(s.hx).use(ae).mount("#app")}},t={};function r(a){var s=t[a];if(void 0!==s)return s.exports;var n=t[a]={exports:{}};return e[a].call(n.exports,n,n.exports,r),n.exports}r.m=e,function(){var e=[];r.O=function(t,a,s,n){if(!a){var o=1/0;for(c=0;c<e.length;c++){a=e[c][0],s=e[c][1],n=e[c][2];for(var i=!0,l=0;l<a.length;l++)(!1&n||o>=n)&&Object.keys(r.O).every((function(e){return r.O[e](a[l])}))?a.splice(l--,1):(i=!1,n<o&&(o=n));if(i){e.splice(c--,1);var u=s();void 0!==u&&(t=u)}}return t}n=n||0;for(var c=e.length;c>0&&e[c-1][2]>n;c--)e[c]=e[c-1];e[c]=[a,s,n]}}(),function(){r.n=function(e){var t=e&&e.__esModule?function(){return e["default"]}:function(){return e};return r.d(t,{a:t}),t}}(),function(){r.d=function(e,t){for(var a in t)r.o(t,a)&&!r.o(e,a)&&Object.defineProperty(e,a,{enumerable:!0,get:t[a]})}}(),function(){r.f={},r.e=function(e){return Promise.all(Object.keys(r.f).reduce((function(t,a){return r.f[a](e,t),t}),[]))}}(),function(){r.u=function(e){return"js/"+e+"."+{28:"42e202b3",33:"3fc2e952",165:"1a1f25b0",241:"c45dc50e",408:"ae36c18a",420:"98f1129d",629:"e879b1cb",661:"c3846107",697:"7bbbf64f",754:"a833597a"}[e]+".js"}}(),function(){r.miniCssF=function(e){}}(),function(){r.g=function(){if("object"===typeof globalThis)return globalThis;try{return this||new Function("return this")()}catch(e){if("object"===typeof window)return window}}()}(),function(){r.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)}}(),function(){var e={},t="frontend:";r.l=function(a,s,n,o){if(e[a])e[a].push(s);else{var i,l;if(void 0!==n)for(var u=document.getElementsByTagName("script"),c=0;c<u.length;c++){var d=u[c];if(d.getAttribute("src")==a||d.getAttribute("data-webpack")==t+n){i=d;break}}i||(l=!0,i=document.createElement("script"),i.charset="utf-8",i.timeout=120,r.nc&&i.setAttribute("nonce",r.nc),i.setAttribute("data-webpack",t+n),i.src=a),e[a]=[s];var h=function(t,r){i.onerror=i.onload=null,clearTimeout(m);var s=e[a];if(delete e[a],i.parentNode&&i.parentNode.removeChild(i),s&&s.forEach((function(e){return e(r)})),t)return t(r)},m=setTimeout(h.bind(null,void 0,{type:"timeout",target:i}),12e4);i.onerror=h.bind(null,i.onerror),i.onload=h.bind(null,i.onload),l&&document.head.appendChild(i)}}}(),function(){r.r=function(e){"undefined"!==typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})}}(),function(){r.p="/"}(),function(){var e={524:0};r.f.j=function(t,a){var s=r.o(e,t)?e[t]:void 0;if(0!==s)if(s)a.push(s[2]);else{var n=new Promise((function(r,a){s=e[t]=[r,a]}));a.push(s[2]=n);var o=r.p+r.u(t),i=new Error,l=function(a){if(r.o(e,t)&&(s=e[t],0!==s&&(e[t]=void 0),s)){var n=a&&("load"===a.type?"missing":a.type),o=a&&a.target&&a.target.src;i.message="Loading chunk "+t+" failed.\n("+n+": "+o+")",i.name="ChunkLoadError",i.type=n,i.request=o,s[1](i)}};r.l(o,l,"chunk-"+t,t)}},r.O.j=function(t){return 0===e[t]};var t=function(t,a){var s,n,o=a[0],i=a[1],l=a[2],u=0;if(o.some((function(t){return 0!==e[t]}))){for(s in i)r.o(i,s)&&(r.m[s]=i[s]);if(l)var c=l(r)}for(t&&t(a);u<o.length;u++)n=o[u],r.o(e,n)&&e[n]&&e[n][0](),e[n]=0;return r.O(c)},a=self["webpackChunkfrontend"]=self["webpackChunkfrontend"]||[];a.forEach(t.bind(null,0)),a.push=t.bind(null,a.push.bind(a))}();var a=r.O(void 0,[504],(function(){return r(5512)}));a=r.O(a)})();
//# sourceMappingURL=app.dc252f4c.js.map