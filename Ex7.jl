#1. Генерация всех размещений с повторениями из n элементов {1,2,...,n} по k
function next_repit_plasement!(p::Vector{T}, n::T) where T<:Integer
    i = findlast(x->(x < n), p) # используется встроенная функция высшего порядка
    # i - это последний первый с конца индекс: x[i] < n, или - nothing, если такого индекса нет (p == [n,n,...,n])
    isnothing(i) && (return nothing)
    p[i] += 1
    p[i+1:end] .= 1 # - устанавливаются минимально-возможные значения
    return p
end
#Тестирование:
n = 2; k = 3
p = ones(Int, k)
println(p)
while !isnothing(p)
    p = next_repit_plasement!(p,n)
    println(p)
end


# 2. Генерация вcех перестановок 1,2,...,n

function next_permute!(p::AbstractVector)
    n = length(p)
    k = 0 # или firstindex(p)-1
    for i in reverse(1:n-1) # или reverse(firstindex(p):lastindex(p)-1)
        if p[i] < p[i+1]
            k=i
            break
        end
    end
    k == firstindex(p)-1 &&  return nothing # т.е. p[begin]>p[begin+1]>...>p[end]
 
    #УТВ: p[k] < p[k+1] > p[k+2] >...> p[end]
    i=k+1
    while i<n && p[i+1]>p[k] # i < lastindex(p) && p[i+1] > p[k]
        i += 1
    end
    #УТВ: p[i] - наименьшее из всех p[k+1:end], большее p[k]
    p[k], p[i] = p[i], p[k]
    #УТВ: по-прежнему p[k+1]>...>p[end]
    reverse!(@view p[k+1:end])
    return p
end

#Тестирование:
# p=[1,2,3,4]
# println(p)
# while !isnothing(p)
#     p = next_permute!(p)
#     println(p)
# end

# 3.1. Первый способ - на основе генерации двоичных кодов чисел 0, 1, ..., 2^n-1

indicator(i::Integer, n::Integer) = digits(Bool, i; base=2, pad=n) # reverse(digits(Bool, i; base=2, pad=n))

# 3.2. Второй способ - на основе непосредственной генерации последовательности индикаторов в лексикографическом порядке

function next_indicator!(indicator::AbstractVector{Bool})
    i = findlast(x->(x==0), indicator)
    isnothing(i) && return nothing
    indicator[i] = 1
    indicator[i+1:end] .= 0
    return indicator 
end

# n=5; A=1:n
# indicator = zeros(Bool, n)
# println(indicator)
# while !isnothing(indicator)
#     A[findall(indicator)] |> println
#     indicator = next_indicator!(indicator)
#     println(indicator)
# end

# 4. Генерация всех k-элементных подмножеств n-элементного множества {1, 2, ..., n}

function next_indicator!(indicator::AbstractVector{Bool}, k)
    # в indicator - ровно k единиц, остальные - нули, но это не проверяется! (фактически k - не используется)
    i=lastindex(indicator)
    while indicator[i]==0
        i-=1
    end
    #УТВ: indic[i]==1 и все справа - нули
    m=0; 
    while i >= firstindex(indicator) && indicator[i]==1 
        m+=1
        i-=1
    end
    if i < firstindex(indicator)
        return nothing
    end
    #УТВ: indicator[i]==0 и справа m>0 единиц, причем indicator[i+1]==1
    indicator[i]=1
    indicator[i+1:i+m-1] .= 0
    indicator[i+m:end] .= 1
    return indicator 
end

# n=6; k=3; A=1:n
# indicator = [zeros(Bool,n-k); ones(Bool,k)]
# A[findall(indicator)] |> println
# for !isnothing(indicator)
#     indicator = next_indicator!(indicator, k)
#     A[findall(indicator)] |> println
# end

# 5. Генерация всех разбиений натурального числа на положительные слагаемые

function next_split!(s::AbstractVector{Integer}, k)
    k == 1 && return nothing
    i = k-1 # - это потому что s[k] увеличивать нельзя
    while i > 1 && s[i-1]==s[i]
        i -= 1
    end
    #УТВ: i == 1 или i - это наименьший индекс: s[i-1] > s[i] и i < k
    s[i] += 1
    #Теперь требуется s[i+1]... - уменьшить минимально-возможным способом (в лексикографическом смысле) 
    r = sum(@view(s[i+1:k]))
    k = i+r-1 # - это с учетом s[i] += 1
    s[i+1:n-k] .= 1
    return s, k
end

# Тестирование:
# n=5; s=ones(Int, n); k=n
# println(s)
# while !isnothing(s)
#     println(s[1:k])
#     s, k = next_split!(s, k)
#     println(s)
# end

# 6. Специальные пользовательские типы и итераторы для генерации рассматриваемых комбинаторных объектов

abstract type AbstractCombinObject
    # value::Vector{Int} - это поле предполагается у всех конкретных типов, наследующих от данного типа
end

Base.iterate(obj::AbstractCombinObject) = (get(obj), nothing)
Base.iterate(obj::AbstractCombinObject, state) = 
    if isnothing(next!(obj)) # == false
        nothing
    else
        (get(obj), nothing)
    end

# 6.1. Размещения с повторениями

struct RepitPlacement{N,K} <: AbstractCombinObject
    value::Vector{Int}
    RepitPlacement{N,K}() where {N, K} = new(ones(Int, K))
end

Base.get(p::RepitPlacement) = p.value
next!(p::RepitPlacement{N,K}) where {N, K} = next_repit_plasement!(p.value, N)

# Тестирование:
# for a in RepitPlasement{2,3}() 
#     println(a)
# end

# 6.2. Перестановки

struct Permute{N} <: AbstractCombinObject
    value:Vector{Int}
    Permute{N}() where N = new(collect(1:N))
end

Base.get(obj::Permute) = obj.value
next!(permute::Permute) = next_permute!(permute.value)

# Тест:
# for p in Permute{4}()
#     println(p)
# end

# 6.3. Все подмножества N-элементного множества

struct Subsets{N} <: AbstractCombinObject
    indicator::Vector{Bool}
    Subsets{N}() where N = new(zeros(Bool, N))
end

Base.get(sub::Subsets) = sub.indicator
next!(sub::Subsets) = next_indicator!(sub.indicator) 

#Тест:
# for sub in Subsets{4}()
#     println(sub)
# end

# 6.4. k-элементные подмоножества n-элементного множества

struct KSubsets{M,K} <: AbstractCombinObject
    indicator::Vector{Bool}
    KSubsets{M, K}() where{M, K} = new([zeros(Bool, length(M)-K); ones(Bool, K)])
end

Base.get(sub::KSubsets) = sub.indicator
next!(sub::KSubsets{M, K}) where{M, K} = next_indicator!(sub.indicator, K) 

#Тест:
# for sub in KSubset{1:6, 3}()
#     sub |> println
# end

# 6.5. Разбиения

struct NSplit{N} <: AbstractCombinObject
    value::Vector{Int}
    num_terms::Int # число слагаемых (это число мы обозначали - k)
    NSplit{N}() where N = new(collect(1:N), N)
end

Base.get(nsplit::NSplit) = nsplit.value[begin:nsplit.num_terms]
function next!(nsplit::NSplit) 
    nsplit.value, nsplit.num_terms = next_split!(nsplit.value, nsplit.num_terms)
    get(psplit)
end

# Тест:
# for s in NSplit{5}()
#     println(s)
# end

#7. Алгоритмы обхода графа "поиск вглубину" и "поиск в ширину"

function dfs(graph::Dict{I, Vector{I}}, vstart::I) where I <: Integer
    stack = [vstart]
    mark = zeros(Bool, length(graph)) # length(graph) = N = число всех вершин графа
    mark[vstart] = true
    while !isempty(stack)
        v = pop!(stack)
        # обработка вершины v
        for u in graph[v]
            if !mark[u]
                mark[u] = true
                push!(stack,u)
            end
        end
    end
end

graph1 = Dict{Int64, Vector{Int64}}([(1, [3]), (2, [4]), (3, [1]), (4, [2, 5]), (5, [4])])
graph2 = Dict{Int64, Vector{Int64}}([(1, [2, 3]), (2, [1, 4]), (3, [1]), (4, [2, 5]), (5, [4])])
graph3 = Dict{Int64, Vector{Int64}}([(1, [2, 3]), (2, [1, 4]), (3, [1, 6]), (4, [2, 5]), (5, [4, 6]), (6, [3, 5])])
graph4 = Dict{Int64, Vector{Int64}}([(1, [2, 3]), (2, [1, 3, 4]), (3, [1, 2]), (4, [2, 5]), (5, [4])])
println(dfs(graph2, 3))

function dbs(graph::Dict{I, Vector{I}}, vstart::I) where I <: Integer
    stack = [vstart]
    mark = zeros(Bool, length(graph)) # length(graph) = N = число всех вершин графа
    mark[vstart] = true
    while !isempty(stack)
        v = pop!(stack)
        # обработка вершины v
        for u in graph[v]
            if !mark[u]
                mark[u] = true
                push!(stack,u)
            end
        end
    end
end