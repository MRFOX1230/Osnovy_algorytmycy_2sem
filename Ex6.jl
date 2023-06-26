using LinearAlgebra
#1. Спроектировать типы `Vector2D` и `Segment2D` с соответсвующими функциями.

Vector2D{T<:Real} = NamedTuple{(:x, :y), Tuple{T,T}}

Base. +(a::Vector2D{T},b::Vector2D{T}) where T = Vector2D{T}(Tuple(a) .+ Tuple(b))
Base. -(a::Vector2D{T}, b::Vector2D{T}) where T = Vector2D{T}(Tuple(a) .- Tuple(b))
Base. *(α::T, a::Vector2D{T}) where T = Vector2D{T}(α.*Tuple(a))
LinearAlgebra.norm(a::Vector2D) = norm(Tuple(a))
# norm(a) - длина вектора, эта функция опредедена в LinearAlgebra
LinearAlgebra.dot(a::Vector2D{T}, b::Vector2D{T}) where T = dot(Tuple(a), Tuple(b))
# dot(a,b)=|a||b|cos(a,b) - скалярное произведение, эта функция определена в
LinearAlgebra
Base. cos(a::Vector2D{T}, b::Vector2D{T}) where T = dot(a,b)/norm(a)/norm(b)
xdot(a::Vector2D{T}, b::Vector2D{T}) where T = a.x*b.y-a.y*b.x
# xdot(a,b)=|a||b|sin(a,b) - косое произведение
Base. sin(a::Vector2D{T}, b::Vector2D{T}) where T = xdot(a,b)/norm(a)/norm(b)
Base. angle(a::Vector2D{T}, b::Vector2D{T}) where T = atan(sin(a,b),cos(a,b))
Base.sign(a::Vector2D{T}, b::Vector2D{T}) where T = sign(sin(a,b))

Segment2D{T<:Real} = NamedTuple{(:A, :B), NTuple{2,Vector2D{T}}}



# 2. Написать функцию, проверяющую, лежат ли две заданные точки по одну сторону от заданной прямой 
# (прямая задается некоторым содержащимся в ней отрезком). 

function is_one(P::Vector2D{T}, Q::Vector2D{T}, s::Segment2D{T}) where T
    l = s.B-s.A
    return sin(l, P-s.A)*sin(l,Q-s.A)>0
end
   
# 3. Написать функцию, проверяющую, лежат ли две заданные точки по одну сторону от заданной кривой 
# (кривая задается уравнением вида F(x,y)=0). 


function F(A::Vector2D{T}) where T
    return sin(A.x) - A.y
end

function is_one_area(F::Function, P::Vector2D{T}, Q::Vector2D{T}) where T
    return F(P)*F(Q)>0
end

# 4. Написать функцию, возвращающую точку пересечения (если она существует) двух заданных отрезков.

function isinner(P::Vector2D, s::Segment2D) 
    return (s.A.x <= P.x <= s.B.x || s.A.x >= P.x >= s.B.x) && 
           (s.A.y <= P.y <= s.B.y || s.A.y >= P.y >= s.B.y)
end

function intersect(s1::Segment2D{T},s2::Segment2D{T}) where T
    A = [s1.B[2]-s1.A[2] s1.A[1]-s1.B[1]
    s2.B[2]-s2.A[2] s2.A[1]-s2.B[1]]
    b = [s1.A[2]*(s1.A[1]-s1.B[1]) + s1.A[1]*(s1.B[2]-s1.A[2])
         s2.A[2]*(s2.A[1]-s2.B[1]) + s2.A[1]*(s2.B[2]-s2.A[2])]
    x,y = A\b
    # !!!! Если матрица A - вырожденная, то произойдет ошибка времени выполнения
    if (isinner((;x, y), s1) == false || isinner((;x, y), s2) == false)
        return nothing
    end
    return (;x, y) #Vector2D{T}((x,y))
end


# m = Segment2D{Int}((Vector2D{Int}((0,0)), Vector2D{Int}((5,5))))
# n = Segment2D{Int}((Vector2D{Int}((3,0)), Vector2D{Int}((0, 10))))
# print(intersect(m, n))

# 5. Написать функцию, проверяющую лежит ли заданная точка внутри заданного многоугольника. 

function point_inside_polygon(point::Vector2D{T}, polygon::Vector{Segment2D{T}}) where {T<:Real}
    angle_sum = 0.0
    n = length(polygon)
    
    for i in 1:n
        segment = polygon[i]
        v1 = segment.A - point
        v2 = segment.B - point
        angle_sum += angle(v1, v2)
    end
    print(angle_sum)
    
    if angle_sum < pi
        return false
    else
        return true
    end
end

# Пример использования
# polygon = [ Segment2D{Float64}((Vector2D{Float64}((0.0, 0.0)), Vector2D{Float64}((1.0, 0.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((1.0, 0.0)), Vector2D{Float64}((1.0, 1.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((1.0, 1.0)), Vector2D{Float64}((0.0, 1.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((0.0, 1.0)), Vector2D{Float64}((0.0, 0.0))))]

# point_inside = point_inside_polygon(Vector2D{Float64}((0.5, 0.5)), polygon)
# print("Point inside polygon: ", point_inside)


# 6. Написать функцию, проверющую, принадлежит ли заданная точка внутри некоторой односвязной области, 
# ограниченной заданной кривой (кривая задается уравнением вида F(x,y)=0).

F(A::Vector2D{T}) where T = return A.x^2 + A.y^2 - 100

function point_inside_func(point::Vector2D{T}, f::Function) where {T<:Real}
    if f(point) <= 0
        return true
    else
        return false
    end 
end
# point = Vector2D{Int}((11, 0))
# println(point_inside_func(point, F))


# 7. Написать функцию, проверяющую, является ли заданный многоугольник выпуклым.
function polygon_convex(polygon::Vector{Segment2D{T}}) where {T<:Real}
    for i in 2:length(polygon)
        if angle(polygon[i-1].B - polygon[i-1].A, polygon[i].B - polygon[i].A) < 0
            return false
        end
        println(angle(polygon[i-1].B - polygon[i-1].A, polygon[i].B - polygon[i].A))
    end
    return true
end

# polygon = [ Segment2D{Float64}((Vector2D{Float64}((0.0, 0.0)), Vector2D{Float64}((1.0, 0.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((1.0, 0.0)), Vector2D{Float64}((4.0, -1.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((4.0, -1.0)), Vector2D{Float64}((1.0, 1.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((1.0, 1.0)), Vector2D{Float64}((0.0, 1.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((0.0, 1.0)), Vector2D{Float64}((0.0, 0.0))))]
# println(polygon_convex(polygon))


#(Из дополнения) Написать функцию, реализующую алгоритм Джарвиса построения выпуклой оболочки заданных точек плоскости
function jarvis(A::Vector{Vector2D{T}}) where {T<:Real}
    n = length(A)
    P = collect(1:n)
    
    # начальная точка
    for i in 2:n
        if A[P[i]].x < A[P[1]].x
            P[i], P[1] = P[1], P[i] # меняем местами номера этих точек
        end
    end
    
    H = [P[1]]
    deleteat!(P, 1)
    push!(P, H[1])
    
    while true
        right = 1
        for i in 2:length(P)
            if angle(A[P[right]] - A[H[end]], A[P[i]] - A[H[end]]) < 0
                right = i
            end
        end
        
        if P[right] == H[1]
            break
        else
            push!(H, P[right])
            deleteat!(P, right)
        end
    end
    res = []
    for i in H
        push!(res, A[i])
    end
    return res
end

polygon = [Vector2D{Float64}((0.0, 0.0)),
           Vector2D{Float64}((3.0, 3.0)),
           Vector2D{Float64}((-12.0, 0.0)),
           Vector2D{Float64}((7.0, 5.0)),
           Vector2D{Float64}((0.0, 6.0)),
           Vector2D{Float64}((4.0, 2.0))]
println("Result: ", jarvis(polygon))


# 8. Написать функцию, реализующую алгоритм Грехома построения выпуклой оболочки заданных точек плоскости.

function graham(A::Vector{Vector2D{T}}) where T
    n = length(A) # число точек
    P = collect(1:n) # список номеров точек
    
    #Определяем самую левую наименьшую точку
    for i in 2:n
        if A[P[i]].x < A[P[1]].x
            P[i], P[1] = P[1], P[i] # меняем местами номера этих точек
        end
    end
    for i in 3:n # сортировка вставкой
        j = i
        while j > 2 && angle(A[P[1]]-A[P[j-1]], A[P[1]]-A[P[j]]) < 0
            P[j], P[j-1] = P[j-1], P[j]
            j -= 1
        end
    end
    S = [P[1], P[2]] # создаем стек
    
    for i in 3:n
        while angle(A[S[end-1]] - A[S[end]], A[P[i]] - A[S[end]]) > 0
            pop!(S) # удаляем последний элемент из стека
        end
        push!(S, P[i]) # добавляем текущий элемент в стек
    end
    res = []
    for i in S
        push!(res, A[i])
    end
    return res
end

# Пример использования
# polygon = [Vector2D{Float64}((0.0, 0.0)),
#            Vector2D{Float64}((3.0, 3.0)),
#            Vector2D{Float64}((-12.0, 0.0)),
#            Vector2D{Float64}((7.0, 5.0)),
#            Vector2D{Float64}((0.0, 6.0)),
#            Vector2D{Float64}((4.0, 2.0))]
# convex_hull = graham(polygon)
# println("Result: ", convex_hull)


# 9. Написать функцию вычисляющую площадь (ориентированную) заданного многоугольника методом трапеций.

function S_trapezoid(polygon::Vector{Segment2D{T}}) where T
    res = 0
    for seg in polygon
        res += 0.5*(seg.A.y+seg.B.y)*(seg.A.x-seg.B.x)
    end
    return abs(res)

end

# polygon = [ Segment2D{Float64}((Vector2D{Float64}((0.0, 0.0)), Vector2D{Float64}((1.0, 0.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((1.0, 0.0)), Vector2D{Float64}((1.0, 1.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((1.0, 1.0)), Vector2D{Float64}((0.0, 1.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((0.0, 1.0)), Vector2D{Float64}((0.0, 0.0))))]
# println(S_trapezoid(polygon))

# 10. Написать функцию вычисляющую площадь (ориентированную) заданного многоугольника методом треугольников.
function S_triangle(polygon::Vector{Segment2D{T}}) where T
    res = 0
    for i in 2:(length(polygon)-1)
        l = polygon[1].A
        m = polygon[i].A
        n = polygon[i+1].A

        v1 = m - l
        v2 = n - l
        res += sqrt(v1.x^2 + v1.y^2) * sqrt(v2.x^2 + v2.y^2) * sin(v1, v2) / 2
    end
    
    return res
end

# polygon = [ Segment2D{Float64}((Vector2D{Float64}((0.0, 0.0)), Vector2D{Float64}((1.0, 0.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((1.0, 0.0)), Vector2D{Float64}((2.0, 0.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((2.0, 0.0)), Vector2D{Float64}((1.0, 1.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((1.0, 1.0)), Vector2D{Float64}((0.0, 1.0)))),
#             Segment2D{Float64}((Vector2D{Float64}((0.0, 1.0)), Vector2D{Float64}((0.0, 0.0))))]
# println(S_triangle(polygon))

