---
title: Mongoose聚合查询
date: 2021-01-29 01:10:06
subtitle: Mongoose-aggregate
tags:
  - MongoDB
categories: [数据库] 
---

在 MongoDB 中，聚合(`aggregate`)主要可以用于多个表之间的联合查询，并且可以进行求和、求平均值、最大与最小值等，在项目中使用也是非常的方便，下面主要是一些常用的操作，更多详细的可以看其[官方文档](https://docs.mongodb.com/manual/reference/operator/aggregation-pipeline/)。

<!-- more -->

## 使用场景
日常开发中经常这些场景，比如文章都有类别字段，而一个类别可以对应多个文章，我们如果需要统计每个类别下的所有文章便可以通过`aggregate`进行查询，或者我们需要统计每个时间段发布的文章做个归档，也可以使用其来完成。

## Definition
常规的定义为：`db.collection.aggregate(pipeline, options)`
主要接收两个参数，其中 **pipeline** 表示数据联立等操作，而 **options** 则为数据库的配置，这里就不多说该属性了。而 **pipeline** 常用的属性有：

1. `$project`：用于指定返回的字段，字段可以是文档中的，也可以添加新的字段，或者排除某个字段。
2. `$match`：用于过滤文档，可以只返回服务我们条件的。
3. `$limit`：用于限制最后查询出的数据，可以配合下面的进行数据分页。
4. `$skip`：用于跳过指定条数的数据，可以用于实现分页。
5. `$unwind`：拆分数据，将一条数据拆分为多条。
6. `$group`：对文档中的数据进行分组，可用于分组或者统计。
7. `$sort`：根据某些字段进行数据的排序。
8. `$geoNear`：距指定点最近到最远的顺序输出文档。
8. `$lookup`：用于将数据进行汇总。

## $lookup(数据填充)
当一个文章类型对应多个文章，而每个文章仅仅对应一个类型，大致为(一对多)，我们要再文章集合中填充类型的信息，便需要该查询方式了。
其基本格式为：
```javascript
{
   $lookup:
     {
       from: <collection to join>,
       localField: <field from the input documents>,
       foreignField: <field from the documents of the "from" collection>,
       as: <output array field>
     }
}
```
例如我们有下面的 **post** 集合数据：
```javascript
db.post.insert([
   { "_id" : 1, "title" : "React", "content" : "*****", "type" : 2 },
   { "_id" : 2, "title" : "mongodb", "content" : "*****", "type" : 8  }
])
```
同样还需要一个 **type** 集合：
```javascript
db.post.insert([
   { "_id" : 2, "name" : "web},
   { "_id" : 8, "name" : "数据库" }
])
```
我们如果需要将指定的 **type** 信息填充到 **post** 中便可以这样写：
```javascript
db.post.aggregate([
   {
     $lookup:
       {
         from: "type",
         localField: "type",
         foreignField: "_id",
         as: "typeInfo"
       }
  }
])
```
这样便通过`$lookup`完成了字段填充，**from** 表示需要联接的集合，**localField** 表示需要和集合进行联立的字段，**foreignField** 表示集合中用于和 localField 对应的字段，**as** 表示别名。其结果为：
```json
[
	{
		"_id" : 1,
		"title" : "React",
		"content" : "*****",
		"type" : 2,
		"typeInfo": [
			{ "_id" : 2, "name" : "web"}
		]
	}, {
		"_id" : 2,
		"title" : "mongodb",
		"content" : "*****",
		"type" : 8,
		"typeInfo": [
			{ "_id" : 8, "name" : "数据库" }
		]
	}
]
```
> 当然我们不可能只遇到一对多，有时甚至需要多对多进行填充，这么我们可以先借助`$unwind`展开数组，然后再填充数据。

## $group(分组)
当文章有添加日期，我们需要根据添加日期的年份对文章进行分组，这样便可以统计每年新增的文章。
默认的格式为：
```javascript
{
  $group:
    {
      _id: <expression>, // Group By Expression
      <field1>: { <accumulator1> : <expression1> },
      ...
    }
 }
```
需要先创建一个 **post** 集合：
```javascript
db.post.insert([
   { "_id" : 1, "title" : "React", "content" : "*****", "type" : 2, createdAt: "2021-03-03 03-08:50"},
   { "_id" : 2, "title" : "mongodb", "content" : "*****", "type" : 8, createdAt: "2020-12-03 09-05:40"  }
])
```
我们可以很轻松的对数据分组，分组之前可以先通过`$project`筛选出需要的字段，`$sort:`对选中的数据排序整理数据：
```javascript
db.post.aggregate([
  {
    $project: {
      _id: 1,
      title: 1,
      createdAt: 1,
    }
  }, {
    $sort: {
      createdAt: -1
    }
  }, {
    $group: {
      _id: {
        $dateToString: { format: "%Y", date: "$createdAt" }
      },
      posts: { $push: "$$ROOT" }
    },
  }, {
    $sort: {
      _id: -1
    }
  }
])
```
`$group`中 **_id** 表示用于分组的字段，其内部的`$dateToString`表示格式化数据，因为我们需要按照年份进行分组，所以要提取出日期中的年份。posts 为数据名称`$push`表示对每个分组添加进数据，`$$ROOT`表示分组出数据的所有字段(可以和 $project 结合使用)。

最后返回数据格式如下：
```json
{
  {
    "_id" "2021"
    'posts': [
      {"_id" : 1, "title" : "React", "content" : "*****", "type" : 2, createdAt: "2021-03-03 03-08:50"}
    ]
  }, {
    "_id" "2020"
    'posts': [
      { "_id" : 2, "title" : "mongodb", "content" : "*****", "type" : 8, createdAt: "2020-12-03 09-05:40"  }
    ]
  }
}
```

## $unwind(数组统计)
可以用于展开数组的字段，例如我们需要统计数组中每个字段出现的次数。
需要先创建一个 **post** 集合：
```javascript
db.post.insert([
	{
	   "_id" : 1,
	   "title" : "React",
	   "content" : "*****",
	   "type" : 2,
	   tags: ["web"]
	}, {
	   "_id" : 2,
	   "title" : "mongodb",
	   "content" : "*****",
	   "type" : 8,
	   tags: ["web", "数据库"]
	}
])
```
我们需要统计数组中每个 **tag** 出现的次数，那么我们可以这样写：
```javascript
db.post.aggregate([{
	$project: {
		tags: 1
	}
}, {
	$unwind: "$tags"
}, {
	$group: {
		_id: "$tags",
		sum: {
			$sum: 1
		}
	}
}])
```
这样先通过`$project`筛选出需要的字段，然后通过`$unwind`展开指定字段，最后使用`$group`进行累加的操作。最后计算的结果为：
```json
[
	{"_id": "web", "sum": 2},
	{"_id": "数据库", "sum": 1}
]
```