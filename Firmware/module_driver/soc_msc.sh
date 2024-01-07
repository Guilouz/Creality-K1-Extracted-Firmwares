insmod soc_msc.ko \
wifi_power_on=PA01 \
wifi_power_on_level=1 \
wifi_reg_on=PE02 \
wifi_reg_on_level=0 \
	msc0_is_enable=0 \
		msc0_cd_method=-1 \
		msc0_bus_width=0 \
		msc0_speed=-1 \
		msc0_max_frequency=0 \
		msc0_cap_power_off_card=0 \
		msc0_cap_mmc_hw_reset=0 \
		msc0_cap_sdio_irq=0 \
		msc0_full_pwr_cycle=0 \
		msc0_keep_power_in_suspend=0 \
		msc0_enable_sdio_wakeup=0 \
		msc0_dsr=0 \
		msc0_pio_mode=0 \
		msc0_enable_autocmd12=0 \
		msc0_enable_cpm_rx_tuning=0 \
		msc0_enable_cpm_tx_tuning=0 \
		msc0_sdio_clk=0 \
		msc0_rst=-1 msc0_rst_enable_level=-1 \
		msc0_wp=-1 msc0_wp_enable_level=-1 \
		msc0_pwr=-1 msc0_pwr_enable_level=-1 \
		msc0_cd=-1 msc0_cd_enable_level=-1 \
		msc0_sdr=-1 msc0_sdr_enable_level=-1 \
	msc1_is_enable=1 \
		msc1_cd_method=non-removable \
		msc1_bus_width=4 \
		msc1_speed=sdio \
		msc1_max_frequency=100000000 \
		msc1_cap_power_off_card=0 \
		msc1_cap_mmc_hw_reset=0 \
		msc1_cap_sdio_irq=0 \
		msc1_full_pwr_cycle=0 \
		msc1_keep_power_in_suspend=y \
		msc1_enable_sdio_wakeup=0 \
		msc1_dsr=0x404 \
		msc1_pio_mode=0 \
		msc1_enable_autocmd12=0 \
		msc1_enable_cpm_rx_tuning=0 \
		msc1_enable_cpm_tx_tuning=0 \
		msc1_sdio_clk=y \
		msc1_rst=-1 msc1_rst_enable_level=-1 \
		msc1_wp=-1 msc1_wp_enable_level=-1 \
		msc1_pwr=-1 msc1_pwr_enable_level=-1 \
		msc1_cd=-1 msc1_cd_enable_level=-1 \
		msc1_sdr=-1 msc1_sdr_enable_level=-1 \
	msc2_is_enable=0 \
		msc2_cd_method=-1 \
		msc2_bus_width=0 \
		msc2_speed=-1 \
		msc2_max_frequency=0 \
		msc2_cap_power_off_card=0 \
		msc2_cap_mmc_hw_reset=0 \
		msc2_cap_sdio_irq=0 \
		msc2_full_pwr_cycle=0 \
		msc2_keep_power_in_suspend=0 \
		msc2_enable_sdio_wakeup=0 \
		msc2_dsr=0 \
		msc2_pio_mode=0 \
		msc2_enable_autocmd12=0 \
		msc2_enable_cpm_rx_tuning=0 \
		msc2_enable_cpm_tx_tuning=0 \
		msc2_sdio_clk=0 \
		msc2_rst=-1 msc2_rst_enable_level=-1 \
		msc2_wp=-1 msc2_wp_enable_level=-1 \
		msc2_pwr=-1 msc2_pwr_enable_level=-1 \
		msc2_cd=-1 msc2_cd_enable_level=-1 \
		msc2_sdr=-1 msc2_sdr_enable_level=-1 \
