package main

import (
	"fmt"
	"math"
	"math/rand"
	"time"
)

const (
	ROCK     = 0
	PAPER    = 1
	SCISSORS = 2
)

func RPSToString(move int) string {
	switch move {
	case ROCK:
		return "Rock"
	case PAPER:
		return "Paper"
	case SCISSORS:
		return "Scissors"
	default:
		return "Unknown"
	}
}

func RPSBestMove(input int) int {
	switch input {
	case ROCK:
		return PAPER
	case PAPER:
		return SCISSORS
	case SCISSORS:
		return ROCK
	default:
		return -1 // Invalid input
	}
}

func RPSRandomMove() int {
	return rand.Intn(3)
}

type RPSNeuralNet struct {
	inputSize           int
	hiddenSize          int
	outputSize          int
	inputHiddenWeights  [][]float64
	hiddenOutputWeights [][]float64
	learningRate        float64
}

func NewRPSNeuralNet(inputSize, hiddenSize, outputSize int, learningRate float64) *RPSNeuralNet {
	nn := &RPSNeuralNet{}
	nn.inputSize = inputSize
	nn.hiddenSize = hiddenSize
	nn.outputSize = outputSize
	nn.learningRate = learningRate
	nn.inputHiddenWeights = make([][]float64, inputSize)
	for i := range nn.inputHiddenWeights {
		nn.inputHiddenWeights[i] = make([]float64, hiddenSize)
		for j := range nn.inputHiddenWeights[i] {
			nn.inputHiddenWeights[i][j] = rand.Float64() - 0.5
		}
	}
	nn.hiddenOutputWeights = make([][]float64, hiddenSize)
	for i := range nn.hiddenOutputWeights {
		nn.hiddenOutputWeights[i] = make([]float64, outputSize)
		for j := range nn.hiddenOutputWeights[i] {
			nn.hiddenOutputWeights[i][j] = rand.Float64() - 0.5
		}
	}
	return nn
}

func (nn *RPSNeuralNet) predict(input []int) int {
	hidden := make([]float64, nn.hiddenSize)
	output := make([]float64, nn.outputSize)

	for i := 0; i < nn.hiddenSize; i++ {
		for j := 0; j < nn.inputSize; j++ {
			hidden[i] += float64(input[j]) * nn.inputHiddenWeights[j][i]
		}
		hidden[i] = sigmoid(hidden[i])
	}

	for i := 0; i < nn.outputSize; i++ {
		for j := 0; j < nn.hiddenSize; j++ {
			output[i] += hidden[j] * nn.hiddenOutputWeights[j][i]
		}
	}

	return argmax(output)
}

func (nn *RPSNeuralNet) train(input []int, correctOutput int) {
	hidden := make([]float64, nn.hiddenSize)
	output := make([]float64, nn.outputSize)
	deltaOutput := make([]float64, nn.outputSize)
	deltaHidden := make([]float64, nn.hiddenSize)

	// Forward pass
	for i := 0; i < nn.hiddenSize; i++ {
		for j := 0; j < nn.inputSize; j++ {
			hidden[i] += float64(input[j]) * nn.inputHiddenWeights[j][i]
		}
		hidden[i] = sigmoid(hidden[i])
	}

	for i := 0; i < nn.outputSize; i++ {
		for j := 0; j < nn.hiddenSize; j++ {
			output[i] += hidden[j] * nn.hiddenOutputWeights[j][i]
		}
	}

	// Backward pass
	for i := 0; i < nn.outputSize; i++ {
		if i == correctOutput {
			deltaOutput[i] = output[i] - 1.0
		} else {
			deltaOutput[i] = output[i]
		}
	}

	for i := 0; i < nn.hiddenSize; i++ {
		for j := 0; j < nn.outputSize; j++ {
			deltaHidden[i] += deltaOutput[j] * nn.hiddenOutputWeights[i][j]
		}
		deltaHidden[i] *= hidden[i] * (1.0 - hidden[i])
	}

	// Update weights
	for i := 0; i < nn.inputSize; i++ {
		for j := 0; j < nn.hiddenSize; j++ {
			nn.inputHiddenWeights[i][j] -= nn.learningRate * deltaHidden[j] * float64(input[i])
		}
	}

	for i := 0; i < nn.hiddenSize; i++ {
		for j := 0; j < nn.outputSize; j++ {
			nn.hiddenOutputWeights[i][j] -= nn.learningRate * deltaOutput[j] * hidden[i]
		}
	}
}

func sigmoid(x float64) float64 {
	return 1.0 / (1.0 + math.Exp(-x))
}

func exp(x float64) float64 {
	return math.Exp(x)
}

func argmax(xs []float64) int {
	max := 0
	for i := 1; i < len(xs); i++ {
		if xs[i] > xs[max] {
			max = i
		}
	}
	return max
}

func main() {
	inputSize := 40
	hiddenSize := 10
	outputSize := 3
	learningRate := 0.1
	nn := NewRPSNeuralNet(inputSize, hiddenSize, outputSize, learningRate)

	lastMoves := make([]int, inputSize)

	wins := 0.0
	draws := 0.0
	round := 1.0

	var predictedMove int
	nextMove := 2

	useNN := true
	useBestMove := true

	for {
		userMove := nextMove
		bestMove := RPSBestMove(userMove)

		if useNN {
			predictedMove = nn.predict(lastMoves)
			// 5% mutation rate
			if rand.Intn(100) >= 95 {
				predictedMove = RPSRandomMove()
			}
		} else {
			predictedMove = RPSRandomMove()
		}

		fmt.Printf("%s vs %s\n", RPSToString(userMove), RPSToString(predictedMove))

		if userMove == predictedMove {
			draws++
			fmt.Println("Draw")
		} else if predictedMove == bestMove {
			wins++
			fmt.Println("I win!")
		} else {
			fmt.Println("You win")
		}
		fmt.Printf("Win rate: %d%%; Draw rate: %d%%\n\n", int(wins/round*100.0), int(draws/round*100.0))

		if useNN {
			n := inputSize / 2
			a := lastMoves[0:n]
			b := lastMoves[n : n+n]
			a = append(a[1:n], userMove)
			b = append(b[1:n], predictedMove)
			c := append([]int{}, a...)
			c = append(c, b...)
			lastMoves = c
			fmt.Printf("My moves: %v\n", a)
			fmt.Printf("PC moves: %v\n", b)
			fmt.Printf("All moves: %v\n\n", c)

			nn.train(lastMoves, bestMove)
		}

		if useBestMove {
			nextMove = RPSBestMove(predictedMove)
			// if rand.Intn(100) >= 75 {
			// 	nextMove = RPSRandomMove()
			// }
		} else {
			nextMove = RPSRandomMove()
		}

		time.Sleep(50 * time.Millisecond)
		round++
	}
}
