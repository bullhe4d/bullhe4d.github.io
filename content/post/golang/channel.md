---
title: "channel实现"
tags : [ "Golang", "面试" ]
categories : [ "Golang" ]
date: 2022-04-02T09:56:44+08:00
---

### 底层结构

ch :=make(chan int ,5),因为channle 是引用类型，所以 make ，然后 ch（在栈）存的是一个指针地址，指针指向 堆上的hChan结构体，

hchan结构体包含如下结构

```go
type hchan struct {
   qcount   uint           // total data in the queue					//缓冲区已经存了多少个元素
   dataqsiz uint           // size of the circular queue			//环形队列的大小
   buf      unsafe.Pointer // points to an array of dataqsiz elements 缓冲区在内存的指针位置（一个数组）
   elemsize uint16		//					//每个元素占多大空间
   closed   uint32							//	关闭状态
   elemtype *_type // element type										//通道中的元素类型 指向类型指针
   sendx    uint   // send index									//	目前数组里写的下表
   recvx    uint   // receive index								//	目前数组里读的下表
   recvq    waitq  // list of recv waiters						//读的等待队列		
   sendq    waitq  // list of send waiters					//写的等待队列			sudog

   // lock protects all fields in hchan, as well as several
   // fields in sudogs blocked on this channel.
   //
   // Do not change another G's status while holding this lock
   // (in particular, do not ready a G), as this can deadlock
   // with stack shrinking.
   lock mutex //多个协程可以调用，所以要加一个互斥锁，
}
```

### 

初始情况下Channel sendx和 recvx的值 都是 0，

使用协程 【G1】每次向channel发送一个数据，sendX 就+1，一直加到等于dataqsize（缓冲区的size），sendX 回到0 【环形队列】

此时缓冲区已经没位置了 G1 进入等待，G1就会进入  sendq 队列中， 

使用【G2】从channel中读一个数据，recvX+1 , 缓冲区的0位置空出来了，此时唤醒recvq 中的G1，G1继续向channel写入数据，会存在0 的位置，sendX+1	



所以引申出来 一个channel在写入的时候，必须保证有缓冲区，并且缓冲区有空闲位置，或者有一个协程在等着recvq

在读取的时候，必须保证缓冲区有数据，如果没有缓冲区，或者缓冲区是空的，就必须要有一个发送队列的协程在等待发送。