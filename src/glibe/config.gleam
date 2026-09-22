import gleam/dict

pub type IntervalSettings {
  IntervalSettings(
    window_sma_tiny_size: Int,
    window_sma_small_size: Int,
    window_sma_middle_size: Int,
    window_sma_large_size: Int,
    bb_multiplier: Float,
    bb_std_fallback: Float,
    kdj_k_period: Int,
    kdj_d_period: Int,
    kdj_m_period: Int,
    branch_exit_leaf_size: Int,
  )
}

pub type SettingsError {
  MissingInterval(String)
  InvalidFormat(String)
}

pub type Settings {
  Settings(intervals: dict.Dict(String, IntervalSettings))
}

pub fn read() -> Result(Settings, SettingsError) {
  // TODO: Read from config/settings.json
  Error(InvalidFormat("Config file reading not implemented yet"))
}

pub fn for_interval(settings: Settings, interval: String) -> Result(IntervalSettings, SettingsError) {
  case dict.get(settings.intervals, interval) {
    Ok(interval_settings) -> Ok(interval_settings)
    Error(_) -> Error(MissingInterval(interval))
  }
}

pub fn stream_config(interval: String) -> Result(StreamConfig, SettingsError) {
  case read() {
    Ok(settings) ->
      case for_interval(settings, interval) {
        Ok(interval_settings) -> Ok(StreamConfig(interval: interval, settings: interval_settings))
        Error(e) -> Error(e)
      }
    Error(e) -> Error(e)
  }
}

pub fn stream_config_or_stop(interval: String) -> StreamConfig {
  case stream_config(interval) {
    Ok(config) -> config
    Error(e) -> panic as describe_error(e)
  }
}

/// Stream configuration for one interval.
pub type StreamConfig {
  StreamConfig(interval: String, settings: IntervalSettings)
}

fn describe_error(error: SettingsError) -> String {
  case error {
    MissingInterval(i) -> "Missing interval: " <> i
    InvalidFormat(msg) -> "Invalid config format: " <> msg
  }
}