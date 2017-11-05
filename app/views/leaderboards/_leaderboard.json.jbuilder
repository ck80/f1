json.extract! leaderboard, :id, :year, :total_points, :created_at, :updated_at
json.url leaderboard_url(leaderboard, format: :json)
