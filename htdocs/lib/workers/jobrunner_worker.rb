class JobrunnerWorker < BackgrounDRb::MetaWorker
  set_worker_name :jobrunner_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def compute(job_id = nil)
    logger.info 'Beginning to process job # ' + job_id;
  end
end

