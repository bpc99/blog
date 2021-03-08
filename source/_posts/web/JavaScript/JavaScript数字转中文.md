---
title: JavaScript数字转中文
date: 2019-07-26 16:54:51
subtitle: js-number-charts
tags:
  - JavaScript
categories: [web]
---
JavaScrip 实现将阿拉伯数字转换为中文读法可以使用对需要处理的数据循环监测的方式处理，在开发过程中有可能遇到，这里简单记录下。

<!-- more -->
## 阿拉伯转中文
中文数字的一些特点：
 1. 每个计数数字都跟着一个权位，权位有：十、百、千、万、亿。
 2. 以“万”为小节，对应一个节权位，万以下没有节权位。
 3. 每个小节内部以“十百千”为权位独立计数。
 4. “十百千”不能连续出现，而“万”和“亿”作为节权位时可以和其他权位连用，如：“二十亿”。

中文判断是否需要添加零：
 1. 以10000为小节，小节的结尾即使是0，也不使用零。
 2. 小节内两个非0数字之间要使用“零”。
 3. 当小节的“千”位是0时（即：1~999），只要不是首小节，都要补“零”。
 
算法的一些说明：
 1. 对“零”的第三个规则，把检测放在循环的最前面并默认为false，可以自然的丢弃最高小节的加零判断。
 2. 单个数字转换用数组实现，var chnNumChar = ["零","一","二","三","四","五","六","七","八","九"]。
 3. 节权位同样用数组实现，var chnUnitSection = ["","万","亿","万亿","亿亿"]。
 4. 节内权位同样用数组实现，var chnUnitChar = ["","十","百","千"]。

小数部分转换如下：
```javascript
function numToChn(num){
  var index =  num.toString().indexOf(".");
  if(index != -1){
    var str = num.toString().slice(index);
    var a = "点";
    for(var i=1;i<str.length;i++){
      a += chnNumChar[parseInt(str[i])];
    }
    return a ;
  }else{
    return '';
  }
}
```
节权位转换如下：
```javascript
function sectionToChinese(section){
  //str:用来存储转换后的中文，chnstr:最终结果，zero:是否需要补零，count:单位
  var str = '', chnstr = '',zero= false,count=0;
  while(section > 0){
    var v = section % 10;  // 对数字取余10，得到的数即为个位数
    if(v === 0){           // 如果数字为零，则对字符串进行补零
      if(zero){
        zero = false;        // 如果遇到连续多次取余都是0，那么只需补一个零即可
        chnstr = chnNumChar[v] + chnstr;
      }
    }else{
      zero = true;           // 第一次取余之后，如果再次取余为零，则需要补零
      str = chnNumChar[v];
      str += chnUnitChar[count];
      chnstr = str + chnstr;
    }
    count++;
    section = Math.floor(section/10);
  }
  return chnstr;
}
```
转换的主函数如下：
```javascript
function TransformToChinese(num){
  // 小数部分
  var a = numToChn(num);
  //舍入
  num = Math.floor(num);
  //用来计算单位
  var unitPos = 0;
  //strIns:权位转换的结果，chnStr:最终结果
  var strIns = '', chnStr = '';
  //是否需要补零
  var needZero = false;
  if(num === 0){
    return chnNumChar[0];
  }
  while(num > 0){
    //取于得到最后一个节权位
    var section = num % 10000;
    if(needZero){
      chnStr = chnNumChar[0] + chnStr;
    }
    strIns = sectionToChinese(section);
    //用来设置节权位单位，如果节权位全是0则不需要添加单位比如100000(十万)
    strIns += (section !== 0) ? chnUnitSection[unitPos] : chnUnitSection[0];
    //拼接最终结果
    chnStr = strIns + chnStr;
    //用来判断是否需要进行补零
    needZero = (section < 1000) && (section > 0);
    //删除这个节权位
    num = Math.floor(num / 10000);
    unitPos++;
  }
  return chnStr+a;
}
```
## 中文转阿拉伯
算法的一些说明：
 1. 将中文权位转换成10的位数。
 2. 对每个权位依次转换成位数并求和。
 3. 零可以直接忽略即可。

中文转阿拉伯需要下面变量：
```javascript
//定义数字转换变量
var chnNumChar = {
  零:0,
  一:1,
  二:2,
  三:3,
  四:4,
  五:5,
  六:6,
  七:7,
  八:8,
  九:9
};
//中文权位转换成10的位数及节权标志
var chnNameValue = {
  十:{value:10, secUnit:false},
  百:{value:100, secUnit:false},
  千:{value:1000, secUnit:false},
  万:{value:10000, secUnit:true},
  亿:{value:100000000, secUnit:true}
}
```
转换的方法如下：
```javascript
function ChineseToNumber(chnStr){
  var rtn = 0;
  var section = 0;
  var number = 0;
  var secUnit = false;
  var str = chnStr.split('');
 
  for(var i = 0; i < str.length; i++){
    var num = chnNumChar[str[i]];
    if(typeof num !== 'undefined'){
      number = num;
      if(i === str.length - 1){
        section += number;
      }
    }else{
      var unit = chnNameValue[str[i]].value;
      secUnit = chnNameValue[str[i]].secUnit;
      if(secUnit){
        section = (section + number) * unit;
        rtn += section;
        section = 0;
      }else{
        section += (number * unit);
      }
      number = 0;
    }
  }
  return rtn + section;
}
```
