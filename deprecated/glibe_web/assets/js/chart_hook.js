// Lightweight Charts hook for Phoenix LiveView
import { createChart } from 'lightweight-charts';

let chart = null;
let candleSeries = null;
let smaTinySeries = null;
let smaMediumSeries = null;
let yinLeafMarkers = [];
let yangLeafMarkers = [];
let yinBranchMarkers = [];
let yangBranchMarkers = [];

export const ChartHook = {
  mounted() {
    this.initChart();
    this.updateChart();
  },

  updated() {
    this.updateChart();
  },

  destroyed() {
    if (chart) {
      chart.remove();
      chart = null;
    }
  },

  initChart() {
    const container = this.el;
    chart = createChart(container, {
      width: container.clientWidth,
      height: 600,
      layout: {
        background: { color: '#ffffff' },
        textColor: '#333',
      },
      grid: {
        vertLines: { color: '#f0f0f0' },
        horzLines: { color: '#f0f0f0' },
      },
      crosshair: {
        mode: 1, // Normal
      },
      rightPriceScale: {
        borderColor: '#d1d4dc',
      },
      timeScale: {
        borderColor: '#d1d4dc',
        timeVisible: true,
        secondsVisible: false,
      },
    });

    // Candlestick series
    candleSeries = chart.addCandlestickSeries({
      upColor: '#26a69a',
      downColor: '#ef5350',
      borderVisible: false,
      wickUpColor: '#26a69a',
      wickDownColor: '#ef5350',
    });

    // SMA Tiny (fast)
    smaTinySeries = chart.addLineSeries({
      color: '#2196F3',
      lineWidth: 1,
      title: 'SMA Tiny',
      priceFormat: { type: 'price', precision: 2, minMove: 0.01 },
    });

    // SMA Medium (slow)
    smaMediumSeries = chart.addLineSeries({
      color: '#FF9800',
      lineWidth: 1,
      title: 'SMA Medium',
      priceFormat: { type: 'price', precision: 2, minMove: 0.01 },
    });

    // Handle resize
    window.addEventListener('resize', () => {
      chart.applyOptions({ width: container.clientWidth });
    });
  },

  updateChart() {
    if (!chart || !candleSeries) return;

    const barsData = JSON.parse(this.el.dataset.bars || '[]');
    const leavesData = JSON.parse(this.el.dataset.leaves || '[]');
    const branchesData = JSON.parse(this.el.dataset.branches || '[]');

    if (barsData.length === 0) return;

    // Convert to Lightweight Charts format (oldest first)
    const bars = barsData.slice().reverse().map(b => ({
      time: b.time,
      open: b.open,
      high: b.high,
      low: b.low,
      close: b.close,
    }));

    const smaTiny = barsData.slice().reverse().map(b => ({
      time: b.time,
      value: b.sma_tiny,
    }));

    const smaMedium = barsData.slice().reverse().map(b => ({
      time: b.time,
      value: b.sma_medium,
    }));

    candleSeries.setData(bars);
    smaTinySeries.setData(smaTiny);
    smaMediumSeries.setData(smaMedium);

    // Update leaf markers
    this.updateLeafMarkers(leavesData, barsData);
    this.updateBranchMarkers(branchesData, barsData);
  },

  updateLeafMarkers(leaves, bars) {
    // Remove old markers
    [...yinLeafMarkers, ...yangLeafMarkers].forEach(m => chart.removeSeries(m));
    yinLeafMarkers = [];
    yangLeafMarkers = [];

    // Create marker series for yin leaves (green triangles up)
    leaves.filter(l => l.type === 'yin').forEach(leaf => {
      const bar = bars.find(b => b.time === leaf.time);
      if (!bar) return;

      const series = chart.addSeries(
        chart.constructor.CustomSeries,
        {
          priceFormat: { type: 'price', precision: 2, minMove: 0.01 },
        }
      );

      // Custom rendering for leaf marker
      series.setData([{
        time: leaf.time,
        position: 'belowBar',
        color: '#4CAF50',
        shape: 'arrowUp',
        text: 'Yin Leaf',
        size: 12,
      }]);

      yinLeafMarkers.push(series);
    });

    // Yang leaves (red triangles down)
    leaves.filter(l => l.type === 'yang').forEach(leaf => {
      const bar = bars.find(b => b.time === leaf.time);
      if (!bar) return;

      const series = chart.addSeries(
        chart.constructor.CustomSeries,
        {
          priceFormat: { type: 'price', precision: 2, minMove: 0.01 },
        }
      );

      series.setData([{
        time: leaf.time,
        position: 'aboveBar',
        color: '#F44336',
        shape: 'arrowDown',
        text: 'Yang Leaf',
        size: 12,
      }]);

      yangLeafMarkers.push(series);
    });
  },

  updateBranchMarkers(branches, bars) {
    // Remove old markers
    [...yinBranchMarkers, ...yangBranchMarkers].forEach(m => chart.removeSeries(m));
    yinBranchMarkers = [];
    yangBranchMarkers = [];

    branches.filter(b => b.type === 'yin').forEach(branch => {
      const entryBar = bars.find(b => b.time === branch.time);
      if (!entryBar) return;

      const series = chart.addSeries(
        chart.constructor.CustomSeries,
        { priceFormat: { type: 'price', precision: 2, minMove: 0.01 } }
      );

      series.setData([{
        time: branch.time,
        position: 'belowBar',
        color: '#4CAF50',
        shape: 'circle',
        text: `Yin Branch\nEntry: ${branch.start_idx}\nExit: ${branch.exit_idx}`,
        size: 16,
      }]);

      yinBranchMarkers.push(series);
    });

    branches.filter(b => b.type === 'yang').forEach(branch => {
      const entryBar = bars.find(b => b.time === branch.time);
      if (!entryBar) return;

      const series = chart.addSeries(
        chart.constructor.CustomSeries,
        { priceFormat: { type: 'price', precision: 2, minMove: 0.01 } }
      );

      series.setData([{
        time: branch.time,
        position: 'aboveBar',
        color: '#F44336',
        shape: 'circle',
        text: `Yang Branch\nEntry: ${branch.start_idx}\nExit: ${branch.exit_idx}`,
        size: 16,
      }]);

      yangBranchMarkers.push(series);
    });
  }
};