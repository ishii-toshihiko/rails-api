# frozen_string_literal: true

module Contacts
  # プロセス内メモリでの簡易制限（ポートフォリオ向け）。Cloud Run はインスタンス単位。
  class RateLimiter
    LIMIT = 5
    WINDOW = 1.hour

    class << self
      def allow?(ip)
        key = "ip:#{ip.presence || 'unknown'}"
        now = Time.current
        entry = store.read(key)

        if entry.nil? || entry[:reset_at] <= now
          store.write(key, { count: 1, reset_at: now + WINDOW })
          return true
        end

        return false if entry[:count] >= LIMIT

        store.write(key, { count: entry[:count] + 1, reset_at: entry[:reset_at] })
        true
      end

      def reset!
        @store = ActiveSupport::Cache::MemoryStore.new
      end

      private

      def store
        @store ||= ActiveSupport::Cache::MemoryStore.new
      end
    end
  end
end
