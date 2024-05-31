---
title: Java8-新特性
date: 2023-12-10 16:29:46
excerpt: Lambda表达式、Stream流、Optional类
index_img: /blogIndexImg/Java8.png
tags: Java
categories: 学习笔记
---



# Java 8 

> Java 8   的新特性

## 一、Lambda表达式

### 1. 基本语法 

- `(参数) -> {方法体}`
- `参数 -> {方法体}`：当只有一个参数时，可以省略小括号
- `(参数) -> 方法体`：当方法体只有一条语句时，可以省略大括号

 > 1. 无参无返回值

  ```java
// 正常写法          
Runnable run1 = new Runnable() {
              @Override
              public void run() {
                  System.out.println("AAA");
              }
          };
          // lambda
          Runnable run2 = () -> System.out.println("BBB");
  ```
 > 2. 一个参数 ， 无返回值

  ```java
// 正常写法             
Consumer<String> con1 = new Consumer<String>() {
              @Override
              public void accept(String s) {
                  System.out.println(s);
              }
          };
          // lambda
          Consumer<String> con2 = (String s) -> {
              System.out.println(s);
          };
          // 当方法体只有一条语句时，大括号可以省略，（有无返回值都一样）
          Consumer<String> con3 = (String s) -> System.out.println(s);
          // 参数类型可以省略   (类型推断)
          Consumer<String> con4 = (s) -> System.out.println(s);
          // 一个参数可以省略括号
          Consumer<String> con5 = s -> System.out.println(s);
  ```
>  3. 有两个以上接口，并且有返回值，有多条语句
```java
// 正常写法        
Comparator<Integer> com1 = new Comparator<Integer>() {
              @Override
              public int compare(Integer o1, Integer o2) {
                  System.out.println("两数比较");
                  return o1.compareTo(o2);
              }
          };
          // lambda
          // 单条语句
          Comparator<Integer> com2 = (o1, o2) -> o1.compareTo(o2);
          // 多条语句
          Comparator<Integer> com3 = (o1, o2) -> {
              System.out.println("HHH");
              return o1.compareTo(o2);
          };
```

  ###  2. 函数式接口

- **Java四个基本函数式接口**

  | 名称                    | 抽象方法          |
  | ----------------------- | ----------------- |
  | Consumer<T>  消费型     | void accept(T t)  |
  | Predicate<T>    判定型  | boolean test(T t) |
  | Supplier<T>      供给型 | T get()           |
  | Function<T,R>   函数型  | R apply(T t)      |

- 示例

  - `Consumer<T>` 消费型

    ```java
    public void functionInterCons() {
        // 正常写法
            cons(500.0, new Consumer<Double>() {
                @Override
                public void accept(Double aDouble) {
                    System.out.printf("消费%.2f元\n", aDouble);
                }
            });
            //lambda
            cons(500.0, money -> System.out.printf("消费%.2f元\n", money));
        }
    
        public void cons(Double money, Consumer<Double> con) {
            con.accept(money);
        }
    ```

  - `Predicate<T>` 判定型

    ```java
    public void functionInterPre() {
            List<String> list = Arrays.asList("AA", "AB", "AC", "CC");
            // 正常写法
        	List<String> res = pres(list, new Predicate<String>() {
                /**
                 * 判定条件
                 */
                @Override
                public boolean test(String s) {
                    return s.contains("A");
                }
            });
            // lambda
            System.out.println(pres(list, s -> s.contains("A")));
    
            System.out.println(res);
        }
    
        public List<String> pres(List<String> list, Predicate<String> pre){
            List<String> res = new ArrayList<>();
            for (String s : list) {
                // pre中只有一个方法
                if (pre.test(s)) {
                    res.add(s);
                }
            }
            return res;
        }
    ```

  - `Supplier<T>` 供给型

    ```java
    public void functionInterSup() {
            // 正常写法
        	supp(new Supplier<String>() {
                @Override
                public String get() {
                    return "str";
                }
            });
            // lambda
            supp(() -> "str");
        }
    
        public void supp(Supplier<String> sup) {
            System.out.println(sup.get());
        }
    ```

  - `Function<T,R>` 函数型

    ```java
    public void functionInterFunc() {
            // 正常写法
        	func((byte) 127, new Function<Byte, Integer>() {
                @Override
                public Integer apply(Byte aByte) {
                    return aByte + 1;
                }
            });
            // lambda
            func((byte) -128, b -> b - 1);
        }
    
        public void func(Byte bytes, Function<Byte, Integer> func) {
            System.out.println(func.apply(bytes));
        }
    ```

### 3. 方法引用

> 
> 实现的方法需要与抽象方法参数类型及返回值类型一致
> 

- 使用格式：`类(或对象) :: 方法名`

  - `类 :: 静态方法名`

    ```Java
    		Supplier<Long> sup2 = System::currentTimeMillis;
            System.out.println(sup2.get());
            // Comparator<T> int compare(T t1 , T t2)
            Comparator<Integer> com1 = (o1, o2) -> Integer.compare(o1, o2);
            Comparator<Integer> com2 = Integer::compare;
    		com1.compare(1, 2)
    ```

  - `类 :: 非静态方法名`

    ```Java
    		// BiPredicate<T,T> boolean test(T t1, T t2)
            BiPredicate<String, String> bip = (s1, s2) -> s1.equals(s2);
            // String boolean s1.equals(s2)
            BiPredicate<String, String> bip2 = String::equals;
    		bip.test("1", "1")
    ```

  - `对象 :: 非静态方法名`

    ```Java
    		Consumer<String> cons = s -> System.out.println(s);
            PrintStream ps = System.out;
            cons = ps::println;
    		cons.accept("str");
    ```

### 4. 构造器引用

> 需要与抽象方法参数类型及返回值类型一致
> 需要实体类中存在对应的有参构造器

- **无参**

  ```Java
  Supplier<Book> sup = () -> new Book();
  Supplier<Book> sup2 = Book::new;
  
  Book b = sup.get();
  ```

- **有参**

  ```Java
  Function<String, Book> func1 = s -> new Book(s);
  Function<String, Book> func2 = Book::new;
  
  Book b = func1.apply("A");
  Book b1 = func2.apply("B");
  ```

- **多参**

  ```Java
  BiFunction<String, Integer, Book> bf1 = (s, i) -> new Book(s, i);
  BiFunction<String, Integer, Book> bf2 = Book::new;
  
  Book b = bf1.apply("C", 10);
  Book b1 = bf2.apply("C", 10)
  ```



### 5. 数组引用

> 将数组看成一个对象 ， 与构造器引用类似

```Java
Function<Integer, String[]> fun1 = len -> new String[len];
Function<Integer, String[]> fun2 = String[]::new;

String[] arr = fun1.apply(5);
String[] arr1 = fun2.apply(5);
```





## 二、Stream API

> Stream流获取操作对象，不改变原对象的值

| 类型   | 定义                        |
| ------ | --------------------------- |
| 顺序流 | Stream<T>  stream()         |
| 并行流 | Stream<T>  parallelStream() |

```java
        List<Book> books = Book.getBooks(10);
//        default Stream<T> stream() 顺序流
        Stream<Book> stream = books.stream();
//        default Stream<T> parallelStream() 并行流
        Stream<Book> praStream = books.parallelStream();
```

### 1. 获取流

- 集合获取流

  ```Java
          List<Book> books = Book.getBooks(10);
  //        default Stream<T> stream() 顺序流
          Stream<Book> stream = books.stream();
  ```

- 数组获取流

  ```Java
   		int[] arr = {1, 2, 3};
          IntStream intStream = Arrays.stream(arr);
  //      支持泛型
          Book[] bookArr = {new Book("a"), new Book("b")};
          Stream<Book> bookStream = Arrays.stream(bookArr);
  ```

- Stream.of() 创建

  ```java
          Stream<Integer> integerStream = Stream.of(1, 2, 3);
          Stream<Book> bookStream1 = Stream.of(new Book());
  ```

- 无限流

  - 迭代

    ```Java
    //  public static<T> Stream<T> 
    //	iterate(final T seed, final UnaryOperator<T> f)
    Stream.iterate(0, t -> t + 2)
        .limit(10).forEach(System.out::println);
    ```

  - 生成

    ```Java
    // public static<T> Stream<T> generate(Supplier<T> S)     
    Stream.generate(Math::random)
        .limit(5).forEach(System.out::println);
    ```



### 2. 中间操作



- **过滤**   `filter<P>`

  > 根据过滤器中的 Predicate 过滤

  ```Java
  // Stream<T> filter(Predicate<? super T> predicate)
  Stream<Book> bookStream = books.stream();
  // filter 过滤价格大于50的书📕
  bookStream.filter(b -> b.getPrice() > 50).forEach(System.out::println);
  ```

- **截断**   `limit(n)`

  > 截取流中前 n 个数据

  ```Java
  books.stream().limit(5).forEach(books1::add);
  ```

- **跳过**   `skip(n)`

  > 跳过前 n 个数据

  ```Java
  books.stream().skip(5).forEach(System.out::println);
  ```

- **筛选**   `distinct()`

  > 通过流产生的 hashCode 和 equals 去除重复元素

  ```Java
  books.stream().distinct().forEach(System.out::println);
  ```



**Map映射操作**

- `map(Function f)`

  > 接收一个函数作为参数，这个函数会作用到每一个元素上，并映射成为一个新的元素

  ```java
  // 将小写字母映射为大写返回
  List<String> list = Arrays.asList("aa", "bb", "cc");
  String[] arr = {"aa", "bb", "cc"};
  // 列表
  list.stream().map(String::toUpperCase).forEach(System.out::println);
  // 数组
  Arrays.stream(arr).map(String::toUpperCase).forEach(System.out::println);
  ```

  - 获取Books中价格大于30的书

    ```Java
    books.stream()
        .map(Book::getPrice)
        .filter(s -> s > 30)
        .forEach(System.out::println);
    ```

- `flatMap(Function f)`

  > 接收一个函数作为参数，将流中的每一个值都转换成一个流，最后将所有的流合成一个流

  - 将 `[[a,a],[b,b],[c,c]] `  变成  ` [a,a,b,b,c,c]`

    ```Java
    // 本类为 StreamA
    // list = Arrays.asList("aa", "bb", "cc");
    
    /**
     * 将字符串转化为流
     */
    public static Stream<Character> strToStream(String str) {
       List<Character> list = new ArrayList<>();
       for (Character c : str.toCharArray()) {
           list.add(c);
       }
       return list.stream();
    }
    
    // 使用普通map 返回值类型为流的集合
    Stream<Stream<Character>> streamStream = 
        list.stream().map(StreamA::strToStream);
        // 遍历每个流中的每一个元素
    streamStream.forEach(s -> {
       s.forEach(System.out::println);
    });
    
    //使用flatMap 返回的类型为一个流
    Stream<Character> characterStream = 
        list.stream().flatMap(StreamA::strToStream);
    
    characterStream.forEach(System.out::println);
    ```

**Sorted排序操作**

- `sorted()`  自然排序 

  ```Java
  List<Integer> list = Arrays.asList(12, 43, 65, 34, 87, 99, 23, 11);
  // (默认从小到大)
  list.stream().sorted().forEach(System.out::println);
  ```

- `sorted(Comparator com)`   自定义排序

  ```java
  List<Book> books = Book.getBooks(10);
  books.stream()
      .sorted(Comparator.comparingInt(Book::getPrice))
      .forEach(System.out::println);
  // 加上 - 号 表示改变顺序
  books.stream()
      .sorted((b1,b2) -> - Integer.compare(b1.getPrice(), b2.getPrice()))
      .forEach(System.out::println);
  
  ```

  

### 3. 终止操作

> 操作结束后会关闭流



**基本常见操作**

- `forEach(Consumer con)`  将元素遍历

  ```java
  list.stream().forEach(System.out::println);
  ```
  
  


- `allMatch(Predicate p)`   检查是否匹配所有元素

  ```java
  books.stream().allMatch(b -> b.getPrice() < 50)
  ```
  
  


- `anyMatch(Predicate p)`   检查是否至少匹配一个元素

  ```java
  books.stream().anyMatch(b -> b.getPrice() > 50)
  ```
  
  


- `noneMatch(Predicate p)` 检查是否 没有匹配的元素

  ```java
  books.stream().noneMatch(b -> b.getName().startsWith("a"))
  ```
  
  


- `findFirst()`  取流中的第一个元素

  ```java
  Optional<Book> first = books.stream().findFirst();
  ```
  
  


- `findAny()`   取流中的任意一个元素

  ```Java
  Optional<Book> any = books.parallelStream().findAny();
  ```
  



**计数操作**

- `count()`    返回流中集合个数

  ```java
  long count = books.stream().filter(b -> b.getPrice() > 50).count();
  ```

  

- `max(Comparator c)`   返回流中的最大值

  ```Java
  Stream<Integer> priceStream = books.stream().map(Book::getPrice);
  Optional<Integer> max = priceStream.max(Integer::compare);
  ```

  

- `min(Comparator c)`   返回流中的最小值

  ```Java
  Optional<Integer> min = books.stream()
      .map(Book::getPrice).min(Integer::compareTo);
  ```



**归约操作**

> 将流中的集合反复结合起来，得到一个值

- `reduce(T identity , BinaryOperator bo)`  得到一个值，返回 `T`

  ```java
  Integer sum = list.stream().reduce(0, (i, j) -> i + j);
  // 或
  Integer sum = list.stream().reduce(0, Integer::sum);
  ```

- `reduce(BinaryOperator bo)`  得到一个值，返回 `Optional<T>`

  ```Java
  Optional<Integer> sumPrice = books.stream()
      .map(Book::getPrice).reduce(Integer::sum);
  ```



**收集操作**

> 将流中的元素转化为其他形式，接收一个Collector接口的实现，用于对流中的对象进行汇总


- `collect(Collector c)`

  ```java
  List<Book> collect = 
      books.stream()
      .filter(b -> b.getPrice() > 50)
      .collect(Collectors.toList());
  // 或
  List<Book> collect2 = 
      books.stream()
      .filter(b -> b.getPrice() > 50)
      .collect(Collectors.toCollection(ArrayList<Book>::new));
  ```
```java
// 常见：
Collectors.toList() 
Collectors.toSet() 
Collectors.toCollection(Supplier s)
```

  

## 三、Optional 类

> 用来预防空指针
>
> 就能不用显示进行空指针检测





### 1. 创建实例

- `Optional.of(T t)`   创建一个 Optional实例 ， t  必须非空

- `Optional.empty()`  创建一个空的Optional 实例

- `Optional.ofNullable(T t)`  创建一个 Optional实例 ， t 可以为空

  ```Java
  public void createOptional(){
     Library lib = new Library();
  // lib = null;
  // 如 lib = null 会报错 空指针 因为of中的示例不能为空
     Optional<Library> olib = Optional.of(lib);
  
  // empty() 创建一个空的Optional 实例
     Optional<Object> empty = Optional.empty();
     System.out.println(empty);
  
  //  ofNullable(T t) 创建一个 Optional实例 ， t可以为空
      Optional<Library> olib1 = Optional.ofNullable(lib);
  
      System.out.println(olib1);
  
  }
  ```



### 2. 获取容器中的对象

- `T get()` 调用的容器中有对象，不能为空
- `T orElse(T other)` 如果容器中有对象则返回 ， 没有则返回指定的 other对象
- `boolean isPresent()` 是否包含对象





### 3. 预防空指针

**例 ：获取书名预防空指针异常**

- 在 `Optional `以前防止空指针

  ```Java
  /**
   * 获取书籍名称
   * 在Optional以前防止空指针
   */
  public String getBookName(Library lib){
      if (lib != null){
      	if (lib.getBook() != null){
      		return lib.getBook().getName();
      	}
       }
       return null;
  }
  ```

- `Optional `防止空指针

  ```Java
  public String getBookNameOp(Library lib){
  
      Optional<Library> libo = Optional.ofNullable(lib);
      // 这里解决 lib == null
      // 如果 lib == null 则返回书名为 AA
      Library lib1 = libo.orElse(new Library(new Book("AA")));
  
  //  此时lib1不为空
  
      Book book1 = lib1.getBook();
  
      Optional<Book> booko = Optional.ofNullable(book1);
      // 这里解决 lib.getBook() == null
      // 如果 lib != null 且 lib.book == null 则返回书名为 BB
      Book book = booko.orElse(new Book("BB"));
  
  //  此时book不为空
      return book.getName();
  }
  ```

