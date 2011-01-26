module Compression
	class HuffmanTree
		Node = Struct.new(:left, :right, :letter, :frequency, :bit, :parent)

		def create_nodes (histogram)
			nodes = []
			@letter_hash = {}
			histogram.each do |letterAndFrequency|
				node = Node.new nil, nil, letterAndFrequency.letter, letterAndFrequency.frequency
				nodes << node
				@letter_hash[node.letter] = node
			end
			return nodes
		end

		def create_parent(nodes)
			right, left = nodes

			left.bit = '0'
			right.bit = '1'

			parentNode = Node.new left, right, '', left.frequency + right.frequency	
			left.parent = right.parent = parentNode
		end
		
		def build (histogram)
			nodes = create_nodes histogram 

			while (nodes.length > 1) do
				parentNode = create_parent nodes

				nodes << parentNode
				nodes.delete parentNode.left
				nodes.delete parentNode.right

				nodes.sort! { |x,y| x.frequency <=> y.frequency }	
			end

			@rootNode = nodes[0]
		end

		def visualize(root = @rootNode, indent = 1)
			return unless root
			letter = root.letter
			if letter == '' then letter = '<>' end
			puts "\t" * indent << letter << "(#{root.bit})"
			visualize(root.left, indent + 1)
			visualize(root.right, indent + 1)
		end

		def get_code(char)
			node = @letter_hash[char]
			codeString = ''
		
			while node do
				codeString << (node.bit || '')
				node = node.parent
			end
			puts "#{char} -> #{codeString.reverse}"
			return codeString.reverse
		end
	end

	class HuffmanEncoder

		LetterFrequency = Struct.new(:letter, :frequency)

		def self.encode(text)
			histogram = find_histogram text

			tree = HuffmanTree.new
			tree.build histogram

			encoded_text = ''
			text.each_char do |char|
				encoded_text << (tree.get_code char)
			end

			return encoded_text
		end


		def self.find_histogram(text)
			letter_frequencies = []
			text.split('').uniq.each do |c|
				count = text.count c
				lf = LetterFrequency.new c, count
				letter_frequencies << lf
			end	
			histogram = letter_frequencies.sort { |x,y| x.frequency <=> y.frequency }
		end
	end
end

