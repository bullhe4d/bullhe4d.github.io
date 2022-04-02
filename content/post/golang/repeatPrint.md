---
title: "重复打印1和2"
tags : [ "Golang", "面试" ]
categories : [ "Golang" ]
date: 2022-04-01T09:56:44+08:00
---

使用channel按顺序重复打印1和2

```go
package main

import (
	"fmt"
)

func main() {
	ch1 := make(chan bool, 1)
	ch2 := make(chan bool)
	Exit := make(chan bool)
	go func() {
		for {
			if ok := <-ch1; ok {
				fmt.Println(1)
				ch2 <- true
			}
		}
	}()

	go func() {
		defer func() {
			close(Exit)
		}()
		for {
			if ok := <-ch2; ok {
				fmt.Println(2)
				ch1 <- true
			}
		}

	}()
	ch1 <- true
	<-Exit
}

```

使用for来控制打印的次数。