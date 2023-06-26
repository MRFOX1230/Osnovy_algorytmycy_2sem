#Практика 1
#1. Написать функцию, вычисляющую НОД двух чисел (или многочленов)

function gcd_(a::T, b::T) where T # - это означает, что тип обоих аргументов один и тот же
    # a0, b0 = a, b
    #ИНВАРИАНТ: НОД(a,b) = HОД(a0,b0)
    while !iszero(b) # - это условие более универсальное, чем b != 0 или b > 0. Функция iszero определена для всех числовых типов. Для пользовательских типов ее надо будет определять
        a, b = b, rem(a,b) # rem(a,b) - это то же самое, что и a % b (есть еще функция mod(a,b))
    end
    return abs(a) # т.к. используется функция rem, то a может получиться отрицательным
end


# 2. Написать функцию, реализующую расширенный алгоритм Евклида, вычисляющий не только НОД, но и коэффициенты его линейного представления.
# **Утверждение.** Пусть d=НОД(a, b), тогда существуют такие целые коэффициенты u, v, что d=u*a+v*b
# Мы спроектируем расширенный алгоритм Евклида с помощью инварианта цикла, и тем самым будет доказаго это утверждение.
# Напомним, что инвариантом цикла (с предусловием) называется некотрое утверждение относительно переменных, изменяющихся в цикле,
#которое справедливо как перед началом выполнения цикла, так и после любого числа его повторений.
# В данном случае в качестве инварианта цикла возьмём **Утверждение**

function gcdx_(a::T, b::T) where T # - это означает, что тип обоих аргументов один и тот же
    # a0, b0 = a, b
    u, v = one(T), zero(T) # - универсальнее, чем 1, 0 и гарантирует стабильность типов переменных
    u_, v_ = v, u
    #ИНВАРИАНТ: НОД(a,b) = HОД(a0,b0) && a = u*a0 + v*b0 && b = u_*a0 + v_ * b0
    while !iszero(b) # - это условие более универсальное, чем b != 0 или b > 0. Функция iszero определена для всех числовых типов. 
                     #   Для пользовательских типов ее надо будет определять
        r, k = rem(a,b), div(a, b) # remdiv(a,b) возвращает кортеж из rem(a,b) и div(a,b)
        a, b = b, r #  r = a - k*b
        u, u_ = u_, u-k*u_ # эти преобразования переменных следуют из инварианта цикла
        v, v_ = v_, v-k*v_
    end
    if isnegative(a) #  использование функции isnegative делает данный алгоритм более универсальным, но эту функцию требуется определить, 
                     #  в том числе и для целых типов
        a, u, v = -a, -u, -v
    end
    return a, u, v 
end

isnegative(a::Integer) = (a < 0) 

# x, y, z = gcdx_(a, b)
# print(x)
# print("\n")
# print(y)
# print("\n")
# print(z)

# 3. С использованием функции gcdx_ реаализовать функцию invmod_(a::T, M::T) where T, которая возвращала бы обратное
#значение инвертируемого элемента (a) кольца вычетов по модулю M, а для необращаемых элементов возвращала бы nothing.
# (если положить M=b  и если d = ua+vb, то при условии, что d=1, a^-1 = u, в противном случае элемент a не обратим)

function invmod_(a::T, M::T) where T
    d, u, v = gcdx_(a, M)
    if (d == 1)
        return u
    else 
        return nothing
    end
end
# print(invmod_(7, 10))

# 4. С использованием функции gcdx_ реализовать функцию diaphant_solve(a::T,b::T,c::T) where T,
#  которая бы возвращала решение дафаетового уравнения ax+by=c, если уравнение разрешимо, и значение nothing - в противном случае
# (если d=ua+vb, и если получилость, что d=1, u, v - есть решение уравнения, в противном случае уранение не разрешимо)

function diaphant_solve(a::T,b::T,c::T) where T
    d, u, v = gcdx_(a, b)
    if (d == 1)
        return u*c, v*c
    else
        return nothing
    end
end

# x, y = diaphant_solve(3,4,7)
# print(x)
# print("\n")
# print(y)

# 5. Для вычислений в кольце вычетов по модулю M определить специальный тип
# и определить для этого типа следующие операции и функции:
# +, -, унарный минус, *, ^, inverse (обращает обратимые элементы), display (определяет, в каком виде значение будет выводиться в REPL)
   
struct Residue{T, M}
    a::T
    function Residue{T, M}(a) where{T,M}
        new(a % M)
    end
end

#Перегружаем операторы для класса колец вычетов
import Base.+
function +(x::Residue{T, M}, y::Residue{T, M}) where{T,M}
    return Residue{T, M}(x.a+y.a)
end
import Base.-
function -(x::Residue{T, M}, y::Residue{T, M}) where{T,M}
    return Residue{T, M}(x.a-y.a)
end
import Base.*
function *(x::Residue{T, M}, y::Residue{T, M}) where{T,M}
    return Residue{T, M}(x.a*y.a)
end
import Base.^
function ^(x::Residue{T, M}, t::T) where{T,M}
    return Residue{T, M}(x.a^t)
end
import Base.-
function -(x::Residue{T, M}) where{T,M}
    return Residue{T, M}(-x.a)
end
function inverse(x::Residue{T, M}) where{T,M}
    d, u, v = gcdx_(a, M)
    if (d == 1)
        return Residue{T, M}(u)
    else
        return x
    end
end
import Base.display
function display(x::Residue{T, M}) where{T,M}
    print(x.a)
end


# import Base.%
# function %(x::Array, m::Int)
#     tmas = x
#     for i in 1:length(x)
#         tmas[i] = x[i] % m
#     end
#     return tmas
# end
import Base.%
function %(x::Polynom{T}, m::Int) where T
    tmas = x.arr
    for i in 1:length(x.arr)
        tmas[i] = x.arr[i] % m
    end
    return Polynom{Int}(tmas)
end

import Base.%
function %(x::Polynom{T}, m::Tuple) where T
    tmas = x.arr
    for i in 1:length(x.arr)
        tmas[i] = x.arr[i] % m[i]
    end
    return Polynom{Int}(tmas)
end


m = Residue{Int,5}(6)
# n = inverse(m)
# display(m)

#6. Реализовать тип Polynom{T} (T - тип коэффициентов многочлена)

struct Polynom{T}
    arr::Array
    # Конструктор, принимающий массив
    function Polynom{T}(arr::Array) where T
        new(arr)
    end
end

#Перегрузка оператора остатка для класса многочленов
import Base.%
function %(x::Polynom{T}, m::Int) where T
    tmas = x.arr
    for i in 1:length(x.arr)
        tmas[i] = x.arr[i] % m
    end
    return Polynom{Int}(tmas)
end


test = Residue{Int, 3}(4)
#print(test)


# 7. Обеспечить взаимодействие типов Residue{M} и Polynom{T}, т.е. добиться, чтобы можно было бы создавать кольцо вычетов многочленов
# (по заданному модулю) и чтобы можно было создавить многочлены с коэффициентами из кольца вычетов.
# При создании кольца вычетов многочленов параметр M должен принимать значение кортежа коэффициентов соответсвующего многочлена.

# Многочлены с коэффициентами из кольца вычетов
a1 = Residue{Int,5}(8)
a2 = Residue{Int,5}(4)
a = [a1, a2]
polres = Polynom{Residue}(a)
println(polres.arr)

# Кольцо вычетов многочленов
# pol = Polynom{Int}([4, 6, 3])
# cor = (2, 3, 2)
# respol = Residue{Polynom, cor}(pol)
# print(respol.a)