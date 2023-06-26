using Pkg
# Pkg.add("ForwardDiff")
# Pkg.add("Plots")
using ForwardDiff
using Plots

#1. Написать обобщенную функцию, реализующую алгоритм быстрого возведения в степень
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

#print(fast_power(2, 3))

#2. На база этой функции написать другую функцию, возвращающую n-ый член последовательности Фибоначчи (сложность - O(log n)).
function fibonachi(n)
    F0 = 0
    F1 = 1
    A = [0 1; 1 1]
    An = [0 1; 1 1]
    if (n < 1)
        return "Value isn't correct"
    else
        n = n - 1
        while n > 0
            if (n % 2 == 1)
                An = An*A
            end
            A = A*A
            n = div(n, 2)
        end

        Fn = F0*An[1, 1] + F1*An[2, 1]
        return Fn
    end
end
# print(fibonachi(5))

# 3. Написать функцию, вычисляющую с заданной точностью log_a x (при произвольном a, не обязательно, что a>1),
#  методом рассмотренном на лекции

function logarifm(a, x)
    z=x; t=1; y=0
    p = 1e-16
    #ИНВАРИАНТ:  x = z^t * a^y
    if (a > 1)
        while (z < 1/a || z > a || t > p)
            if (z < 1/a)
                z *= a # это перобразование направлено на достижения условия окончания цикла
                y -= t # тогда необходимрсть этого преобразования следует из инварианта цикла
            elseif (z > a)
                z /= a # это перобразование направлено на достижения условия окончания цикла
                y += t # тогда необходимрсть этого преобразования следует из инварианта цикла
            elseif (t > p)
                t /= 2 # это перобразование направлено на достижения условия окончания цикла
                z *= z # тогда необходимрсть этого преобразования следует из инварианта цикла
            end
        end
    elseif (0 < a < 1)
        while (z > 1/a || z < a || t > p)
            if (z > 1/a)
                z *= a # это перобразование направлено на достижения условия окончания цикла
                y -= t # тогда необходимрсть этого преобразования следует из инварианта цикла
            elseif (z < a)
                z /= a # это перобразование направлено на достижения условия окончания цикла
                y += t # тогда необходимрсть этого преобразования следует из инварианта цикла
            elseif (t > p)
                t /= 2 # это перобразование направлено на достижения условия окончания цикла
                z *= z # тогда необходимрсть этого преобразования следует из инварианта цикла
            end
        end
    else
        return "Values aren't correct"
    end
    return y
end
# print(logarifm(0.5, 2))

# 4. Написать функцию, реализующую приближенное решение уравнения вида f(x)=0 методом деления отрезка пополам

function bisection(f::Function, a, b, epsilon)
    @assert f(a)*f(b) < 0
    @assert a < b
    f_a = f(a)
    #ИНВАРИАНТ: f_a*f(b) < 0
    while b-a > epsilon
        t = (a+b)/2
        f_t = f(t)
        if f_t == 0
            return t
        elseif f_a*f_t < 0
            b=t
        else
            a, f_a = t, f_t
        end
    return (a+b)/2
    end
end

#5. Найти приближенное решение уравнения   cos x = x методом деления отрезка пополам.
# f(x) = cos(x) - x
# print(bisection(x->cos(x)-x, -1, 10, 1e-6))

# 6. Написать обобщенную функцию, реализующую метод Ньютона приближенного решения уравнения вида f(x)=0
#7. Методом Ньютона найти приближеннное решение уравнения cos x = x.
function newton(f::Function, x, epsilon; num_max = 10)
    dx = -f(x)/ForwardDiff.derivative(f, x) #dx = -r(x) = -f(x)/f'(x)
    k = 0
    while abs(dx) > epsilon && k <= num_max
        dx = -f(x)/ForwardDiff.derivative(f, x) #dx = -r(x) = -f(x)/f'(x)
        x += dx
        k += 1
    end
    k > num_max && @warn("Требуемая точность не достигнута")
    return x
end
# f(x) = cos(x) - x
# print(newton(f, 1, 1e-4))

#8. Методом Ньютона найти приближеннное значение какого-либо вещественного корня многочлена, заданного своими коэффициенами.
# fmn(x) = x^2 + 3*x - 4
# print(newton(fmn, 0.2, 1e-4))

#7. Построить фрактал Кэлли с помощью функций графического пакета Plots.jl или Makie.jl.

#Фрактал Ньютона (Келли)
#Метод Ньютона
function newtonfractal(f::Function, z, epsilon; num_max = 10)
    dz = -f(z)/(3*z^2) #dx = -r(x) = -f(x)/f'(x)
    k = 0
    while abs(dz) > epsilon && k <= num_max
        dz = -f(z)/(3*z^2) #dz = -r(z) = -f(z)/f'(z)
        z += dz
        k += 1
    end
    x1 = 1; x2 = -0.5 - (sqrt(3)/2)*im; x3 = -0.5 + (sqrt(3)/2)*im
    if abs(x1 - z) <= 1e-4
        return 40
    elseif abs(x2 - z) <= 1e-4
        return 50
    elseif abs(x3 - z) <= 1e-4
        return 60
    end
    return 100
end

f(z) = z^3 - 1
a = 3
len = 1000
x = range(-a/2, a/2, len)
y = range(-a/2, a/2, len)
plot(x, y, (x, y) -> newtonfractal(f, x + y*im, 1e-4), st = :heatmap, aspect_ratio = 1)



#Фрактал Мандельбротта
# function mandelbrot(c)
#     z = 0
#     for i in 1:100
#         z = z^2 + c
#         if abs(z) > 2
#             return i-1
#         end
#     end
#     return 100
# end
# function plot_mandelbrot(x_min, x_max, y_min, y_max, resolution)
#     x = range(x_min, x_max, length = resolution)
#     y = range(y_min, y_max, length = resolution)
#     plot(x, y, (x, y) -> mandelbrot(x + y*im), st = :heatmap, aspect_ratio = 1)
# end
# plot_mandelbrot(-2, 1, -1.5, 1.5, 1000)