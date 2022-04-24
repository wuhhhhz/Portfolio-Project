use demo;
select * From `bank`;

#1 產出下列資訊
#帳務年月	累積存款金額	存款人數	存款筆數
#2019/1	          37994	         3	        3
#2019/2	         84404	        4	         5

select date_format(Successtime, '%Y/%m') as '帳務年月',
sum(Money) as '累積存款金額',count(distinct(userid)) as '存款人數', count(Type) as '存款筆數'
from bank where Type = 'Deposit'
group by year(Successtime), month(Successtime)

#2 產出下列資訊
#  UserID	UserName	累積存款	累積提款
#  102056	白林青	      43943	        6036
#  101642	王彩荷		  58609
#   …	      …	         …	             …

select userid,UserName,
sum(case type when 'withdraw' then Money else 0 end) as withdraw, 
sum(case type when 'deposit' then Money else 0 end) as deposit from bank
group by userid order by userid desc

#3.請查詢出哪位 User 的累積存款最高？
#UserID	 UserName	累積存款

select userid,UserName,
sum(Money) as 累積存款 from bank where type = 'deposit'
group by userid order by 累積存款 desc limit 1

#4 承上題，請查詢出 [ 累積存款最高 User ]  的所有明細
select bank. * from bank 
inner join(select userid,UserName, sum(Money) as 累積存款 from bank where type = 'deposit'
group by userid  order by 累積存款 desc limit 1) as top 
on bank.userid = top.userid

#5.請將每位 User 的存款紀錄，依存款金額、由小到大、進行排序，並加上排名順序編號。最後，以排名編號、UserID 進行遞增排序

#UserID	UserName	Type  Money	    Rank
#10,121	溫進	Deposit	  12,171     1
#10,285	饒洪全	Deposit	  7,665	     1
#10,285	饒洪全	Deposit	  12,418	 2
#10,285	饒洪全	Deposit	  12,565     3

select userid, username, money, type,
rank() over(PARTITION BY userid ORDER BY money ASC) as 排名
from bank where type = 'deposit' order by 排名, userid
