# 1. Написать функцию, вычисляющую n-ю частичную сумму ряда Тейлора (Маклорена)
# функции exp(x) для произвольно заданного значения аргумента x.
# Сложность алгоритма должна иметь оценку O(n).

function teylor(x, n)
    if (n < 1)
        return "n isn't correct"
    end
    result = 1
    fact = 1
    for a in 1:(n-1)
        fact *= a
        result += x^a/fact
    end
    return result

end
# print(teylor(1, 10))

# 2. Написать функцию, вычиляющую значение exp(x) с машинной точностью (с
# максимально возможной в арифметике с плавающей точкой).
# print(teylor(1, 18))


# 3. Написать функцию, вычисляющую функцию Бесселя заданного целого
# неотрицательного порядка по ее ряду Тейлора с машинной точностью. Для
# этого сначала вывести соответствующую рекуррентную формулу,
# обеспечивающую возможность эффективного вычисления. Построить
# семейство графиков этих функций для нескольких порядков, начиная с нулевого
# порядка.
using Plots

#Быстрое возведение в степень
function fast_power(base, exponent)
    result = 1
    while exponent > 0
        if (exponent % 2 == 1)
            result *= base
        end
        base *= base
        exponent = div(exponent, 2)
    end
    return result
end

function bessel(x, k) # k - порядок
    # Первый шаг
    x *= 0.5
    term = fast_power(x, k) / factorial(k)
    sum = term

    # Следующие шаги
    x *= -x
    for i in 1:21
        term *= x / (i * (i + k))
        sum += term
    end
    return sum
end

a = 30 # длина рисунка (квадрата)
resolution = 1000 # разрешение
x = range(-a/2, a/2, resolution)
y = bessel.(x, 0)
p1 = plot(x, bessel.(x, 1))
plot(p1, x, y)


#4. Реализовать алгорим, реализующий обратный ход алгоритма Жордана-Гаусса

using LinearAlgebra
#Неоптимизированный код
# function reverse_gauss(A::AbstractMatrix{T}, b::AbstractVector{T}) where T
#     x = similar(b)
#     N = size(A, 1)
#     for k in 0:N-1
#         x[N-k] = (b[N-k] - sum(A[N-k,N-k+1:end] .* x[N-k+1:end])) / A[N-k,N-k]
#     end
#     return x
# end


#Оптимизированный код
function reverse_gauss(A::AbstractMatrix{T}, b::AbstractVector{T}) where T
    x = similar(b)
    N = size(A, 1)
    for k in 0:N-1
        x[N-k] = (b[N-k] - sumprod(@view(A[N-k,N-k+1:end]), @view(x[N-k+1:end]))) / A[N-k,N-k]
    end
    return x
end
@inline function sumprod(A::AbstractVector{T}, B::AbstractVector{T}) where T
    s = T(0)
    @inbounds for i in eachindex(A)
        s = fma(A[i], B[i], s)
    end
    return s
end
   

function random_upper_triangular(N::Integer)
    A = randn(N,N)
    _, A = lu(A)
    return A
end
#A = random_upper_triangular(3)
# print("A = ")
# print(A)
# print("\n")
# b = [1.0, 2.0, 3.0]
# print(reverse_gauss(A, b))

# 5. Реализовать алгоритм, осуществляющий приведение матрицы к ступенчатому виду

@inline function swap!(A,B)
    @inbounds for i in eachindex(A)
    A[i], B[i] = B[i], A[i]
    end
end
   

function transform_to_steps!(A::AbstractMatrix; epsilon = 1e-7)
    @inbounds for k ∈ 1:size(A, 1)
        absval, Δk = findmax(abs, @view(A[k:end,k]))
        (absval <= epsilon) && throw("Вырожденая матрица")
        Δk > 1 && swap!(@view(A[k,k:end]), @view(A[k+Δk-1,k:end]))
        for i ∈ k+1:size(A,1)
            t = A[i,k]/A[k,k]
            @. @views A[i,k:end] = A[i,k:end] - t * A[k,k:end]
        end
    end
    return A
end

# matrix = [1.0 2.0 2.0; 3.0 12.0 8.0; 2.0 -1.0 8.0]
# print(transform_to_steps!(matrix))

# 6. Реализовать алгоритм, реализующий метод Жордана-Гаусса решение СЛАУ для
# произвольной невырожденной матрицы (достаточно хорошо обусловленной).

function solve_sla(A::AbstractMatrix{T}, b::AbstractVector{T}) where T
    newA = transform_to_steps!(A; epsilon = 10*sqrt(eps(T))*maximum(abs, A))
    return reverse_gauss(newA, b)
end

# A = [1.0 2.0 2.0; 3.0 12.0 8.0; 2.0 -1.0 8.0]
# #print(typeof(A))
# b = [1.0, 2.0, 3.0]
# print(solve_sla(A, b))
   

# 7. Постараться обеспечить максимально возможную производительность
# алгорима решения СЛАУ; провести временные замеры с помощью макроса
# @time для систем большого размера (порядка 1000)
# Матрицы большого размера генерировать с помощью встроенной функции randn .

# a = 1000 #размер матрицы и вектора
# A = randn(a, a)
# b = randn(a)


# @time begin
#     solve_sla(A, b)
# end

#изначально для матрицы из 1000*1000 элементов в среднем 1.5 с
#после оптимизации получилось около 1.2 с

# 8. Написать функцию, возвращающую ранг произвольной прямоугольной матрицы
# (реализуется на базе приведения матрицы к ступенчатому виду).

function allmtransform_to_steps!(A::AbstractMatrix; epsilon = 1e-7)
    @inbounds for k ∈ 1:size(A, 1)
        absval, Δk = findmax(abs, @view(A[k:end,k]))
        Δk > 1 && swap!(@view(A[k,k:end]), @view(A[k+Δk-1,k:end]))
        for i ∈ k+1:size(A,1)
            t = A[i,k]/A[k,k]
            @. @views A[i,k:end] = A[i,k:end] - t * A[k,k:end]
        end
    end
    return A
end

function rangmatrix(m)
    newm = allmtransform_to_steps!(m)
    rows, cols = size(newm)  # Получение размеров матрицы
    rang = rows
    l = 1
    k = 0
    for ai in newm'
        if ai == 0.0
            k += 1
        end
        if l == cols
            if l == k
                rang -= 1
            end
            l = 0
            k = 0
        end
        l += 1
    end
    return rang
end

# A = [1.0 2.0 2.0; 3.0 12.0 8.0; 6.0 2.0 16.0]
# print(rangmatrix(A))


# 9. Написать функцию, возвращающую определитель произвольной квадратной
# матрицы (реализуется на основе приведения матрицы к ступенчатому виду).

function determinant(m)
    newm = transform_to_steps!(m)
    rows, cols = size(newm)  # Получение размеров матрицы
    deter = 1
    l = 1
    k = 1
    for ai in newm'
        if l == k
            deter *= ai
        end
        if l == cols
            k += 1
            l = 0
        end
        l += 1
    end
    return deter
end

# A = [1.0 2.0 2.0; 3.0 12.0 8.0; 6.0 2.0 16.0]
# print(transform_to_steps!(A))
# print("\n\n")
# print(determinant(A))