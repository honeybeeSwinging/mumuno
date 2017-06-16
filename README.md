# NoteBook


# AD

用于启动页的广告，支持本地缓存

# MMKit

对YY大神的膜拜项目，主要是在拜读大神的代码过程中对未知的问题进行的一些总结

# MMToast

提示窗一共有顶部、中部、底部三种样式，颜色也是黑底白字，白底黑字，模糊样式三种

# 算法之swift实现

通过swift来实现常见的算法题解，首先来看一下算法中两个比较重要的点

1.时间复杂度
算法的时间复杂度是一个`**函数**`，它定量描述了该算法的运行时间,常见的算法时间复杂度排序

常见的时间复杂度计算

## O(1)
````C++
Temp=i;
i=j;
j=temp;                    

以上三条单个语句的频度均为1，该程序段的执行时间是一个与问题规模n无关的常数。算法的时间复杂度为常数阶，记作T(n)=O(1)。如果算法的执行时间不随着问题规模n的增加而增长，即使算法中有上千条语句，其执行时间也不过是一个较大的常数。此类算法的时间复杂度是O(1)。
````

## O(n^2)
````C++
2.1.
sum=0；                  （一次）
for(i=1;i<=n;i++) {      （n次 ）
    for(j=1;j<=n;j++){ 
         sum++//n^2次 
    }
}
解：T(n)=2n^2+n+1 =O(n^2)

2.2.   
for (i=1;i<n;i++) { 
    y = y+1;    ①                  
    for(j=0;j<=(2*n);j++) {   
        x++; ② 
    }
}
语句1的频度是n-1语句
语句2的频度是(n-1)*(2n+1)=2n^2-n-1
f(n)=2n^2-n-1+(n-1)=2n^2-2
该程序的时间复杂度T(n)=O(n^2)
````

## O(n)      
````C++                                              
2.3.

a=0;
b=1;                ①
for(i=1;i<=n;i++) { ②   
       s=a+b;　　 　 ③
       b=a;　　　 　 ④  
       a=s;　　　 　 ⑤
}
题解：
语句1的频度：2,        
语句2的频度： n,        
语句3的频度： n-1,        
语句4的频度：n-1,    
语句5的频度：n-1,                                  
T(n)=2+n+3(n-1)=4n-1=O(n).
````                                                                                               

## O(log2n)
````C++
i=1;       ①
while (i<=n) {
    i=i*2; ②
}
题解： 
语句1的频度是1,  
设语句2的频度是f(n),   则：2^f(n)<=n;f(n)<=log2n    
取最大值f(n)=log2n,
T(n)=O(log2n )
````

## O(n^3)
````C++
2.5.
for(i=0;i<n;i++) {  
       for(j=0;j<i;j++)  {
          for(k=0;k<j;k++)
             x=x+2;  
       }
    }
题解：
当i=m,
j=k的时候,内层循环的次数为k当i=m时, j 可以取 0,1,...,m-1 , 所以这里最内循环共进行了0+1+...+m-1=(m-1)m/2次所以,i从0取到n, 则循环共进行了: 0+(1-1)*1/2+...+(n-1)n/2=n(n+1)(n-1)/6所以时间复杂度为O(n^3).
````

我们还应该区分算法的最坏情况的行为和期望行为。如快速排序的最坏情况运行时间是 O(n^2)，但期望时间是 O(nlogn)。通过每次都仔细 地选择基准值，我们有可能把平方情况 (即O(n^2)情况)的概率减小到几乎等于 0。在实际中，精心实现的快速排序一般都能以 (O(nlogn)时间运行。

下面是一些常用的记法：
访问数组中的元素是常数时间操作，或说O(1)操作。一个算法如 果能在每个步骤去掉一半数据元素，如二分检索，通常它就取 O(logn)时间。用strcmp比较两个具有n个字符的串需要O(n)时间。常规的矩阵乘算法是O(n^3)，因为算出每个元素都需要将n对元素相乘并加到一起，所有元素的个数是n^2。
指数时间算法通常来源于需要求出所有可能结果。例如，n个元 素的集合共有2n个子集,所以要求出所有子集的算法将是O(2n)的。指数算法一般说来是太复杂了，除非n的值非常小，因为，在 这个问题中增加一个元素就导致运行时间加倍。不幸的是，确实有许多问题 (如著名的“巡回售货员问题” )，到目前为止找到的算法都是指数的。如果我们真的遇到这种情况，通常应该用寻找近似最佳结果的算法替代之。

2.空间复杂度
