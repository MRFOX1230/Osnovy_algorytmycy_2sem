# 1. Реализовать функции, аналогичные встроенным функциям
#sort, sort!, sortperm, sortperm! на основе алгоритма сортировки вставками.
function insert_sort!(vector)
    n = 1
    # ИНВАРИАНТ: срез vector[1:n] - отсортирован
    while n < length(vector) 
        n += 1
        i = n
        while i > 1 && vector[i-1] > vector[i]
            vector[i], vector[i-1] = vector[i-1], vector[i]
            i -= 1
        end
        #УТВ: vector[1]<=...<=vector[n]
    end
    return vector
end
function index_insert_sort!(vector)
    n = 1
    vindex = []
    for j in 1:length(vector)
        push!(vindex, j)
    end
    # ИНВАРИАНТ: срез vector[1:n] - отсортирован
    while n < length(vector) 
        n += 1
        i = n
        while i > 1 && vector[i-1] > vector[i]
            vector[i], vector[i-1] = vector[i-1], vector[i]
            vindex[i], vindex[i-1] = vindex[i-1], vindex[i]
            i -= 1
        end
        #УТВ: vector[1]<=...<=vector[n]
    end
    return vindex
end

function Sort(mas)
    newmas = mas
    return insert_sort!(newmas)
end
function Sort!(mas)
    return insert_sort!(mas)
end
function Sortperm(mas)
    return index_insert_sort!(mas)
end
function Sortperm!(mas)
    index = index_insert_sort!(mas)
    return index
end

# m = [1, 32, 12, 546]
# sort(m)
# print(m)

# 2. Реализовать алгоритм сортировки "расчесыванием", который базируется на сортировке "пузырьком". Исследовать эффективность
# этого алгоритма в равнении с пузырьковой сортировкой (на больших массивах делать времннные замеры).

function comb_sort(arr)
    gap = length(arr)
    shrink = 1.2473309
    sorted = false
    while (!sorted)
        gap = Int(floor(gap / shrink))
        if (gap <= 1)
            gap = 1
            sorted = true
        end
        
        i = 1
        while (i + gap <= length(arr))
            if (arr[i] > arr[i + gap])
                arr[i], arr[i + gap] = arr[i + gap], arr[i]
                sorted = false
            end
            i += 1
        end
    end
    
    return arr
end

# m = [1, 32, 12, 546]
# print(comb_sort(m))

#В результате сортировки массива на 50k элементов быстрая сортировка оказалась примерно в 16 раз быстрее сортировки пузырьком
#(0.5 с против 8 с)

# 3. Реализовать алгоритм сортировки Шелла, который базируется на сортировке вставками.
# Исследовать эффективность этого алгоритма в сравнении с сортировкой вставками (на больших массивах делать времннные замеры).

function shell_sort!(
    a; 
    step_series = (length(a)÷2^i for i in 1:Int(floor(log2(length(a))))) 
)
    for step in step_series
        for i in firstindex(a):lastindex(a)-step
            j = i
            while j >= firstindex(a) && a[j] > a[j+step]
                a[j], a[j+step] = a[j+step], a[j]
                j -= step
            end
        end
    end
    return a
end

# m = []
# for i in 1:50000
#     push!(m, rand())
# end
#Sort(m) #Сортировка вставками
# shell_sort!(m) #Сортировка Шелла
# print("End")

#Проверим сортировки на время для массива на 50000 элементов
#Сортировка Шелла - около 0.5 секунд
#Сортировка вставками - 20 секунд

#4. Реализовать алгоритм сортировки слияниями. Исследовать эффективность этого алгоритма в сравнении с предыдущми алгоритмами.

@inline function Base.merge!(a1, a2, a3)::Nothing # @inline - делает функцию "встраиваемой", т.е. во время компиляции ее тело будет встроено непосредственно в код вызывающей функции (за счет этого происходит экономия на времени, затрачиваемым на вызов функции; это время очень небольшое, но тем не менее)
    i1, i2, i3 = 1, 1, 1
    @inbounds while i1 <= length(a1) && i2 <= length(a2) # @inbounds - передотвращает проверки выхода за пределы массивов
        if a1[i1] < a2[i2]
            a3[i3] = a1[i1]
            i1 += 1
        else
            a3[i3] = a2[i2]
            i2 += 1
        end
        i3 += 1
    end
    @inbounds if i1 > length(a1)
        a3[i3:end] .= @view(a2[i2:end]) # Если бы тут было: a3[i3:end] = @view(a2[i2:end]), то это привело бы к лишним аллокациям (к созданию промежуточного массива)
    else
        a3[i3:end] .= @view(a1[i1:end])
    end
    nothing
end

function merge_sort!(a)
    b = similar(a) # - вспомогательный массив того же размера и типа, что и массив a
    N = length(a)
    n = 1 # n - текущая длина блоков
    @inbounds while n < N
        K = div(N,2n) # - число имеющихся пар блоков длины n
        for k in 0:K-1
            merge!(@view(a[(1:n).+k*2n]), @view(a[(n+1:2n).+k*2n]), @view(b[(1:2n).+k*2n]))
        end
        if N - K*2n > n # - осталось еще смержить блок длины n и более короткий остаток
            merge!(@view(a[(1:n).+K*2n]), @view(a[K*2n+n+1:end]), @view(b[K*2n+1:end]))
        elseif 0 < N - K*2n <= n # - оставшуюся короткую часть мержить не с чем
            b[K*2n+1:end] .= @view(a[K*2n+1:end])
        end
        a, b = b, a
        n *= 2
    end
    if isodd(log2(n)) # - если цикл был выполнен нечетное число раз, то b - это исходная ссылка на массив (на внешний массив), и a - это ссылка на вспомогательный массив (локальный)
        b .= a # b = copy(a) - это было бы не то же самое, т.к. при этом получилась бы ссылка на новый массив, который создает функция copy
        a = b
    end
    return a # - исходная ссылка на внешний массив (проверить, что это так, можно с помощью ===)
end

# m = []
# for i in 1:50000
#     push!(m, rand())
# end
# merge_sort!(m)
# print("end")

#Для массива из 50000 получается около 1 секунды

#5. Реализовать алгоритм сортировки Хоара. Исследовать эффективность этого алгоритма в сравнении с предыдущми алгоритмами.

function part_sort!(A, b)
    N = length(A)
    K=0
    L=0
    M=N
    #ИНВАРИАНТ: A[1:K] < b && A[K+1:L] == b && A[M+1:N] > b
    while L < M 
        if A[L+1] == b
            L += 1
        elseif A[L+1] > b
            A[L+1], A[M] = A[M], A[L+1]
            M -= 1
        else # if A[L+1] < b
            L += 1; K += 1
            A[L], A[K] = A[K], A[L]
        end
    end
    return K, M+1 
    # 1:K и M+1:N - эти диапазоны индексов определяют ещё не 
    # отсортированные части массива A
end

function quick_sort!(A)
    if isempty(A)
        return A
    end
    N = length(A)
    K, M = part_sort!(A, A[rand(1:N)]) # - "базовый" элемент массива выбирается случайнам образом
    quick_sort!(@view A[1:K])
    quick_sort!(@view A[M:N])
    return A
end
# m = [1, 32, 12, 546]
# print(quick_sort!(m))

#На 50000 элементов алгоритм срабатывает примерно за 0.5 секунды

#6. Реализовать вычисление медианы массива на основе процедуры Хоара.

function mediana(m)
    n = length(m)
    index = div(n, 2)
    if n % 2 == 1
        return((quick_sort!(m))[index + 1])
    end
    return "The number of elements in the massive is even"
end
# m = [1, 32, 12, 546, 1]
# print(mediana(m))

#7. Реализовать алгоритм сортировки за линейное время.
function calc_sort!(A::AbstractVector{<:Integer})
    min_val, max_val = extrema(A)
    num_val = zeros(Int, max_val-min_val+1) # - число всех возможных значений
    for val in A
        num_val[val-min_val+1] += 1
    end  
    k = 0
    for (i, num) in enumerate(num_val)
        A[k+1:k+num] .= min_val+i-1
        k += num
    end
    return A
end
# m = [1, 32, 12, 546, 1]
# print(calc_sort!(m))