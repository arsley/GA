# require 'pp'
# require 'pry-byebug'

# current generetion => 10
# next generation => 10
# generation lasts => 3 or 4 (better)
# binary encoding
# tournament selection => 4
# two-point crossover
# crossover's probability => 0.9
# mutation => substitution
# mutation's probability => 0.01

class Knapsack
  def initialize(conf)
    @conf = conf
    @capacity = @conf[:capacity]
    @weights  = @conf[:weight]
    @prices   = @conf[:price]
    @names    = @conf[:name]
    # element counts
    @elements = @conf[:name].length
    # current, next generation (for binary)
    @cg   = []
    @ng   = []
    # temp generation
    @tg   = []
    # evaluted price
    @ep   = []
    # baggages weight
    @bw   = []
    # selection size, selected gene(index)
    @ss   = 4
    @s1   = -1
    @s2   = -1
    # now generation
    @gene = 1
  end

  def run
    gene_init
    until @gene == 6
      evaluation
      reproduction until @ng.length == 10
      migrate_next_gene
    end
    result
  end

  def reproduction
    selection
    crossover if probability >= 90
    mutation
    @ng << @tg[@s1]
    @ng << @tg[@s2]
  end

  def migrate_next_gene
    @gene += 1
    @cg.clear
    @cg = @ng.dup
    @ng.clear
  end

  # generate first generation
  # todo; more efficiency than this
  def gene_init
    bin = [0, 1]
    10.times do
      temp = []
      @elements.times do
        temp << bin.sample
      end
      @cg << temp
    end
  end

  # generate probability for crossover, mutation
  def probability
    rand(1..100)
  end

  # evaluate each individual
  def evaluation
    @ep.clear
    @bw.clear
    @cg.each do |i|
      ep_temp = 0
      bw_temp = 0
      i.each_with_index do |gene, index|
        if gene == 1
          ep_temp += @prices[index]
          bw_temp += @weights[index]
        end
      end
      @ep << (bw_temp.round(1) > @capacity ? -1 : ep_temp.round(1))
      @bw << (bw_temp.round(1) > @capacity ? -1 : bw_temp.round(1))
    end
  end

  # select from evaluated prices
  # todo; avoid to conflict (@s1, @s2)
  def selection
    @tg.clear
    s1_temp, s2_temp = -1, -1
    s1_temp = @ep.sample(@ss).max until s1_temp != -1
    s2_temp = @ep.sample(@ss).max until s2_temp != -1
    @s1 = @ep.index(s1_temp)
    @s2 = @ep.index(s2_temp)
    @tg[@s1] = @cg[@s1]
    @tg[@s2] = @cg[@s2]
  end

  # do two-point crossover
  # todo; avoid to conflict (p1, p2)
  def crossover
    p1 = rand(@elements)
    p2 = rand(@elements)
    # to modify to p1 must be smaller than p2
    p1, p2 = p2, p1 if p2 < p1
    (p1..p2).each do |index|
      @tg[@s1][index], @tg[@s2][index] = @tg[@s2][index], @tg[@s1][index]
    end
  end

  # do substitution (mutation)
  def mutation
    @tg[@s1].each_with_index do |gene, index|
      @tg[@s1][index] = (gene == 0 ? 1 : 0) if probability == 1
    end
    @tg[@s2].each_with_index do |gene, index|
      @tg[@s2][index] = (gene == 0 ? 1 : 0) if probability == 1
    end
  end

  def result
    evaluation
    price = @ep.max
    res_i = @ep.index(price)
    weight = @bw[res_i]
    baggage = in_bag(@cg[res_i])
    puts "gene  : #{@cg[res_i]}"
    puts "price : #{price}"
    puts "weight: #{weight}"
    puts "inside: #{baggage}"
  end

  def in_bag(inside)
    baggage = []
    inside.each_with_index do |m, index|
      baggage << @names[index] if m == 1
    end
    baggage
  end
end

#################################################

init = {
  capacity: 5,
  weight: [0.9, 1.1, 0.7, 1.4, 0.5, 1.3, 1.1, 1.6],
  price: [1.0, 1.3, 0.9, 1.5, 0.5, 1.1, 1.2, 1.4],
  name: %w(b1 b2 b3 b4 b5 b6 b7 b8)
}

Knapsack.new(init).run

# error
# GA.rb:112:in `each': Interrupt
#         from GA.rb:112:in `max'
#         from GA.rb:112:in `selection'
#         from GA.rb:57:in `reproduction'
#         from GA.rb:51:in `run'
#         from GA.rb:43:in `start'
#         from GA.rb:152:in `<main>'

# wrong answer
# gene  :[0, 1, 1, 1, 1, 1, 1, 0]
# price : -1
# weight: -1
# inside: ["b2", "b3", "b4", "b5", "b6", "b7"]
