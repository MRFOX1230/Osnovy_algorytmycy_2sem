# 1. Написать функцию, осуществлющую проверку, является ли заданное целое
# число простым; оценка сложности должна быть O(sqrt(n)).

function isprime(n::IntType) where IntType <: Integer # является ли заданное число простым
     for d in 2:IntType(ceil(sqrt(n)))
        if n % d == 0
            return false
        end
     end
     return true
end
# print(isprime(13))

# 2. Написать функцию, реализующую "решето" Эратосфена, т.е. возвращающую
# вектор всех простых чисел, не превосходящих заданное число n.

function eratosphenes_sieve(n::Integer)
    prime_indexes = ones(Bool, n)
    prime_indexes[begin] = false
    i = 2
    prime_indexes[i^2:i:n] .= false # - четные вычеркнуты
    i=3
    #ИНВАРИАНТ: i - простое нечетное
    while i <= n
        prime_indexes[i^2:2i:n] .= false
        # т.к. i^2 - нечетное, то шаг тут можно взять равным 2i, т.к. нечетное+нечетное=четное, а все четные уже вычеркнуты
        i+=1
        while i <= n && prime_indexes[i] == false
            i+=1
        end
    # i - очередное простое (первое не вычеркунутое)
    end
    return findall(prime_indexes)
end
# print(eratosphenes_sieve(80))

# 3. Написать функцию, осуществляющую разложение заданного целого числа на
# степени его простых делителей.

function factorize(n::IntType) where IntType <: Integer
    list = NamedTuple{(:div, :deg), Tuple{IntType, IntType}}[]
    for p in eratosphenes_sieve(Int(ceil(n/2)))
        k = degree(n, p) # кратность делителя
        if k > 0
            push!(list, (div=p, deg=k))
        end
    end
    return list
end

function degree(n, p) # кратность делителя `p` числа `n`
    k=0
    n, r = divrem(n,p)
    while n > 0 && r == 0
        k += 1
        n, r = divrem(n,p)
    end
    return k
end
# print(factorize(12))

# 4. Реализовать функцию, осуществляющую вычисление сренего квадратического
# отклонения (от среднего значения) заданного числового массива за один
# проход этого массива

function meanstd(aaa)
    T = eltype(aaa)
    n = 0; s¹ = zero(T); s² = zero(T)
    for a ∈ aaa
        n += 1; s¹ += a; s² += a*a
    end
    mean = s¹ / n
    return sqrt(s²/n - mean*mean)
end
mas = [1 2 3 4 5]
# print(meanstd(mas))

# 5. Написать функции, позволяющие взаимное преобразование различных способов представления корневых деревьев.
# Рассмотреть следующие способы представления корневого дерева:
# -с помощью вложенных векторов;
# -с помощью списка смежностей, представленного словарём (Dict{Int,Vector{Union{Int, Nothing}})
# -с помощью связанных структур

# 6. Для дерева, представленного вложенными векторами, реализовать следующие функции
# -функцию, возвращающую высоту дерева
# -функцию, возвращающую, число листьев дерева
# -функцию, возвращающую число всех вершин дерева
# -функцию, возвращающую наибольшую валентность по выходу вершин дерева
# -функцию, возвращающую среднюю длину пути к вершинам дерева


function trace(tree::Vector)
    if isempty(tree)
        return
    end
        
    println(tree[end]) # "обработка" корня
    
    for subtree in tree[1:end-1]
        trace(subtree)
    end
end

#--------------------------------------------------------------
function convert!(intree::Vector, outtree::Dict{Int,Vector{Union{Int, Nothing}}})
    if isempty(intree)
        return
    end
    list = []
    for subtree in intree[1:end-1]
        if isempty(subtree)
            push!(list, nothing)
            continue
        end 
        push!(list, subtree[end])
        convert!(subtree, outtree)
    end
    outtree[intree[end]] = list
    return outtree
end

#--------------------------------------

struct Node
    index::Int
    childs::Vector      
end

function convert(intree::Dict{Int,Vector{Union{Int, Nothing}}}, root::Union{Int, Nothing})::Union{Node, Nothing}
    if isnothing(root)
        return nothing
    end
    node = Node(root, [])
    for sub_root in intree[root]
        push!(node.childs, convert(intree, sub_root))
    end
    return node
end

#--------------------------------------------------------------
#Высота дерева
function tree_height(tree::Vector)
    if isempty(tree)
        return 0
    end
    
    max_height = 0
    
    for subtree in tree[1:end-1]
        height = 1 + tree_height(subtree)
        if height > max_height
            max_height = height
        end
    end
    return max_height
end

#--------------------------------------------------------------
#Кол-во листьев дерева
function tree_leaves_count(tree::Vector)
    if isempty(tree)
        return 0
    end
    count = 0
    k = 0
    for subtree in tree[1:end-1]
        if !isempty(subtree)
            k = 1
        end
        count += tree_leaves_count(subtree)
    end
    if k == 0
        return 1
    end
    return count
end

#--------------------------------------------------------------
#Кол-во вершин дерева
function tree_nodes_count(tree::Vector)
    if isempty(tree)
        return 0
    end
    count = 0
    for subtree in tree[1:end-1]
        if !isempty(subtree)
            count += tree_nodes_count(subtree)
        end
    end
    count += 1
    return count
end

#Кол-во вершин, которые имеют наследников
# function tree_nodes_count(tree::Vector)
#     if isempty(tree)
#         return 0
#     end
#     count = 0
#     k = 0
#     for subtree in tree[1:end-1]
#         if !isempty(subtree)
#             count += tree_nodes_count(subtree)
#             k = 1
#         end
#     end
#     if k == 1
#         count += 1
#     end
#     return count
# end


#--------------------------------------------------------------
#Наибольшая валентность по выходу вершин дерева
function valence(tree::Vector)
    if isempty(tree)
        return 0
    end
    max_valence = 0
    k = 0
    for subtree in tree[1:end-1]
        if !isempty(subtree)
            tree_nodes_count(subtree)
            k += 1
        end
    end
    if k > max_valence
        max_valence = k
    end
    return max_valence
end


#--------------------------------------------------------------
#Средняя длина пути к вершинам дерева

function tree_nodes_avg(tree::Vector)
    way = 0
    function rec(tree::Vector, depth = 1)
        if isempty(tree) #если дерево пусто то результат 0
            return 0
        end
        
        for subtree in tree[1:end-1] #проходимся по дочерним деревьям
            if !isempty(subtree) #если дерево имеет наследника subtree
                way += depth
                rec(subtree, depth + 1)
            end
        end
    end

    rec(tree)
    return way / tree_nodes_count(tree)
end

#-------------------------- TEST
intree = [[[[], 6], [], 2], [[[], 4], [[], 5], 3], [[[], 3], [[], 2], 13], 1]
tree = Dict{Int, Vector{Union{Int, Nothing}}}()
convert!(intree, tree)

root_node = convert(tree, 1)
#print(root_node.childs)

# println("Height: ", tree_height(intree), "\n")
# println("Leaves Count: ", tree_leaves_count(intree), "\n")
# println("Node Count: ", tree_nodes_count(intree), "\n")
# println("Max Valency: ", valence(intree), "\n")
#println("Average Path Length: ", tree_nodes_avg(intree))