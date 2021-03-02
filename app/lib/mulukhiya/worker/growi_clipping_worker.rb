module Mulukhiya
  class GrowiClippingWorker < ClippingWorker
    sidekiq_options lock: :until_executed

    def perform(params)
      return unless account = Environment.account_class[params['account_id']]
      return unless account.growi
      account.growi.clip(body: create_body(params))
    end
  end
end
