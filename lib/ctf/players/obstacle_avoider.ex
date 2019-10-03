defmodule Ctf.Players.ObstacleAvoider do
  @behaviour Ctf.Player
  alias Ctf.{Player, Game, Board, Flag}

  # all I do is drive around and avoid obstacles randomly

  @moves [:fire, :clockwise, :counterclockwise, :move]

  @impl Ctf.Player
  def name() do
    "Obstacle Avoider Tank #{trunc(:rand.uniform() * 100)}"
  end

  @impl Ctf.Player
  def turn(game = %Game{}, player = %Player{}, _state) do
    {accumulate_turns([], game, player, 3), Enum.random(1..10000)}
  end

  defp accumulate_turns(acc, _game, _player, 0) do
    Enum.reverse(acc)
  end

  defp accumulate_turns(acc, game, %Player{x: x, y: y} = player, remaining) do
    {displace_x, displace_y} = Player.get_displacement(player)
    new_cell_x = displace_x + x
    new_cell_y = displace_y + y

    case Board.get_cell_contents(game.board, new_cell_x, new_cell_y) do
      # go forward if you can
      [] ->
        new_player = Player.move(player)
        accumulate_turns([{:move, 1} | acc], game, new_player, remaining - 1)
      # who knows, we might win here
      [%Flag{}] ->
        new_player = Player.move(player)
        accumulate_turns([{:move, 1} | acc], game, new_player, remaining - 1)
      # otherwise turn clockwise (until you can eventually move forward)
      _ ->
        new_player = Player.rotate(player, :clockwise)
        accumulate_turns([{:clockwise, 1} | acc], game, new_player, remaining - 1)
    end
  end
end