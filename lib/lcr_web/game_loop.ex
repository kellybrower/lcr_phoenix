defmodule Lcr.GameLoop do
  alias Lcr.Player
  alias Lcr.GameState
  alias Lcr.Dice
  alias Lcr.Repo

  def start_game(player_names) do
    players =
      Enum.map(player_names, fn name ->
        %Player{name: name}
        |> Player.changeset(%{name: name})
        |> Repo.insert!()
      end)

    state = %GameState{players: players, current_turn: 0, center_pot: 0}
    play_rounds(state)
  end

  defp play_rounds(state) do
    IO.inspect(state, label: "Current state")

    if game_over?(state) do
      {:game_over, winner(state)}
    else
      state
      |> play_turn()
      |> play_rounds()
    end
  end

  defp play_turn(state) do
    player = Enum.at(state.players, state.current_turn)
    number_of_rolls = Kernel.min(player.chips, 3)

    Enum.reduce(1..number_of_rolls, state, fn _, acc_state ->
      roll_dice_and_update_state(acc_state)
    end)
    |> GameState.next_turn()
  end

  defp roll_dice_and_update_state(state) do
    player = Enum.at(state.players, state.current_turn)

    case Dice.roll() do
      "L" -> handle_left_roll(state, player)
      "R" -> handle_right_roll(state, player)
      "C" -> handle_center_roll(state, player)
      # No action on dot roll
      "." -> state
    end
  end

  defp handle_left_roll(state, player) do
    left_index =
      (Enum.find_index(state.players, fn p -> p.name == player.name end) - 1 +
         length(state.players))
      |> rem(length(state.players))

    left_player = Enum.at(state.players, left_index)
    updated_players = update_players(state.players, player, left_player)
    %Lcr.GameState{state | players: updated_players}
  end

  defp handle_right_roll(state, player) do
    right_index =
      (Enum.find_index(state.players, fn p -> p.name == player.name end) + 1)
      |> rem(length(state.players))

    right_player = Enum.at(state.players, right_index)
    updated_players = update_players(state.players, player, right_player)
    %Lcr.GameState{state | players: updated_players}
  end

  defp handle_center_roll(state, player) do
    updated_player = Player.remove_chip(player)
    updated_players = replace_player(state.players, player, updated_player)
    %Lcr.GameState{state | players: updated_players, center_pot: state.center_pot + 1}
  end

  defp update_players(players, from_player, to_player) do
    from_player_updated = Player.remove_chip(from_player)
    to_player_updated = Player.add_chip(to_player)

    players
    |> replace_player(from_player, from_player_updated)
    |> replace_player(to_player, to_player_updated)
  end

  defp replace_player(players, original, updated) do
    Enum.map(players, fn player ->
      if player.name == original.name, do: updated, else: player
    end)
  end

  defp game_over?(state) do
    Enum.count(state.players, fn player -> player.chips > 0 end) == 1
  end

  defp winner(state) do
    Enum.find(state.players, fn player -> player.chips > 0 end)
  end
end
