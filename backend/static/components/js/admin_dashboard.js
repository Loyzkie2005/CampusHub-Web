document.addEventListener('DOMContentLoaded', function () {

    // ── Floating chat toggle (opens upward, FB Messenger style) ──
    const chatBtn  = document.getElementById('floatingChatBtn');
    const chatMenu = document.getElementById('floatingChatMenu');
    if (chatBtn && chatMenu) {
        chatBtn.addEventListener('click', function (e) {
            e.stopPropagation();
            const isOpen = chatMenu.classList.toggle('chat-open');
            chatBtn.setAttribute('aria-expanded', isOpen);
        });
        document.addEventListener('click', function (e) {
            if (!chatMenu.contains(e.target) && e.target !== chatBtn) {
                chatMenu.classList.remove('chat-open');
                chatBtn.setAttribute('aria-expanded', 'false');
            }
        });
    }

    // ── Active nav item ──
    document.querySelectorAll('.sidebar-nav .sidebar-item').forEach(function (item) {
        item.addEventListener('click', function (e) {
            const href = this.getAttribute('href');
            if (href && href !== '#') return;
            e.preventDefault();
            document.querySelectorAll('.sidebar-nav .sidebar-item').forEach(i => i.classList.remove('active'));
            this.classList.add('active');
        });
    });

    // ── Revenue Line Chart ──
    const labels7  = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const labels14 = ['W1 Mon','W1 Tue','W1 Wed','W1 Thu','W1 Fri','W1 Sat','W1 Sun','W2 Mon','W2 Tue','W2 Wed','W2 Thu','W2 Fri','W2 Sat','W2 Sun'];
    const labels30 = Array.from({length:30}, (_,i) => `Day ${i+1}`);

    const data7  = { revenue:[8200,9100,8700,11200,13400,12100,10800], orders:[38,42,39,51,62,57,49] };
    const data14 = { revenue:[7800,8500,9200,8900,10100,11400,10200,9800,10500,11800,12400,13100,12700,11900], orders:[35,39,42,40,46,52,47,45,48,54,57,60,58,55] };
    const data30 = { revenue:Array.from({length:30},()=>Math.floor(7000+Math.random()*7000)), orders:Array.from({length:30},()=>Math.floor(30+Math.random()*60)) };

    const ctx = document.getElementById('revenueChart').getContext('2d');
    const rg = ctx.createLinearGradient(0,0,0,300);
    rg.addColorStop(0,'rgba(26,86,219,0.18)'); rg.addColorStop(1,'rgba(26,86,219,0)');
    const og = ctx.createLinearGradient(0,0,0,300);
    og.addColorStop(0,'rgba(14,165,233,0.12)'); og.addColorStop(1,'rgba(14,165,233,0)');

    const chart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels7,
            datasets: [
                { label:'Revenue', data:data7.revenue, borderColor:'#1a56db', backgroundColor:rg, borderWidth:2.5, pointRadius:4, pointBackgroundColor:'#1a56db', pointHoverRadius:6, tension:0.4, fill:true, yAxisID:'y' },
                { label:'Orders',  data:data7.orders,  borderColor:'#0ea5e9', backgroundColor:og, borderWidth:2, borderDash:[6,4], pointRadius:3, pointBackgroundColor:'#0ea5e9', pointHoverRadius:5, tension:0.4, fill:true, yAxisID:'y1' }
            ]
        },
        options: {
            responsive: true,
            interaction: { mode:'index', intersect:false },
            plugins: {
                legend: { display:false },
                tooltip: {
                    backgroundColor:'#fff', titleColor:'#374151', bodyColor:'#6b7280',
                    borderColor:'#e5e7eb', borderWidth:1, padding:12,
                    callbacks: {
                        label: c => c.dataset.label === 'Orders'
                            ? ` Orders: ${c.parsed.y}`
                            : ` Revenue: \u20b1${c.parsed.y.toLocaleString()}`
                    }
                }
            },
            scales: {
                x:  { grid:{display:false}, ticks:{color:'#9ca3af', font:{family:'Montserrat',size:11}} },
                y:  { grid:{color:'#f3f4f6'}, position:'left',  ticks:{color:'#9ca3af', font:{family:'Montserrat',size:11}, callback: v => '\u20b1'+(v/1000).toFixed(0)+'K'} },
                y1: { grid:{display:false},  position:'right', ticks:{color:'#0ea5e9', font:{family:'Montserrat',size:11}}, title:{display:true, text:'Orders', color:'#0ea5e9', font:{size:11}} }
            }
        }
    });

    const cf = document.getElementById('chartFilter');
    if (cf) cf.addEventListener('change', function () {
        const d = this.value==='7' ? data7 : this.value==='14' ? data14 : data30;
        const l = this.value==='7' ? labels7 : this.value==='14' ? labels14 : labels30;
        chart.data.labels = l;
        chart.data.datasets[0].data = d.revenue;
        chart.data.datasets[1].data = d.orders;
        chart.update();
    });

    // ── Pie Chart ──
    const pieColors = ['#1a56db','#0ea5e9','#10b981','#f59e0b','#8b5cf6','#ef4444'];
    const pieLabels = ['Food & Drinks','Books','Uniforms','Electronics','Supplies','Others'];
    const pieData   = [32,18,14,12,15,9];
    const pieCtx = document.getElementById('categoryChart').getContext('2d');
    const cv = document.getElementById('pieCenterValue');
    const cl = document.getElementById('pieCenterLabel');

    new Chart(pieCtx, {
        type: 'doughnut',
        data: { labels:pieLabels, datasets:[{ data:pieData, backgroundColor:pieColors, borderWidth:2, borderColor:'#fff', hoverOffset:8 }] },
        options: {
            responsive:true, cutout:'65%',
            plugins: {
                legend: { display:false },
                tooltip: { backgroundColor:'#fff', titleColor:'#374151', bodyColor:'#6b7280', borderColor:'#e5e7eb', borderWidth:1, padding:10, callbacks:{ label: c => ` ${c.label}: ${c.parsed}%` } }
            }
        },
        plugins: [{
            id: 'ct',
            afterDraw(chart) {
                const a = chart.getActiveElements();
                if (cv) cv.textContent = a.length ? pieData[a[0].index]+'%' : '100%';
                if (cl) cl.textContent = a.length ? pieLabels[a[0].index] : 'Total';
            }
        }]
    });

    const leg = document.getElementById('pieLegend');
    if (leg) pieLabels.forEach((label, i) => {
        leg.innerHTML += `<div class="pie-legend-item"><span class="pie-legend-dot" style="background:${pieColors[i]}"></span><span class="pie-legend-label">${label}</span><span class="pie-legend-value">${pieData[i]}%</span></div>`;
    });

    // ── Bar Chart: Booking Summary ──
    const bookingData = {
        day:   { labels:['Mon','Tue','Wed','Thu','Fri','Sat','Sun'], data:[12,18,10,15,20,8,14] },
        week:  { labels:['Week 1','Week 2','Week 3','Week 4'], data:[74,88,65,92] },
        month: { labels:['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'], data:[120,145,98,160,175,140,155,130,168,190,145,200] }
    };
    const bEl = document.getElementById('bookingChart');
    if (bEl) {
        const bCtx = bEl.getContext('2d');
        const bg = bCtx.createLinearGradient(0,0,0,250);
        bg.addColorStop(0,'rgba(26,86,219,0.85)'); bg.addColorStop(1,'rgba(26,86,219,0.4)');

        const bookingChart = new Chart(bCtx, {
            type: 'bar',
            data: { labels:bookingData.day.labels, datasets:[{ label:'Bookings', data:bookingData.day.data, backgroundColor:bg, borderRadius:8, borderSkipped:false, maxBarThickness:40 }] },
            options: {
                responsive: true,
                plugins: { legend:{display:false}, tooltip:{ backgroundColor:'#fff', titleColor:'#374151', bodyColor:'#6b7280', borderColor:'#e5e7eb', borderWidth:1, padding:10, callbacks:{ label: c => ` Bookings: ${c.parsed.y}` } } },
                scales: { x:{grid:{display:false},ticks:{color:'#9ca3af',font:{family:'Montserrat',size:11}}}, y:{grid:{color:'#f3f4f6'},beginAtZero:true,ticks:{color:'#9ca3af',font:{family:'Montserrat',size:11},stepSize:5}} }
            }
        });

        const bf = document.getElementById('bookingFilter');
        if (bf) bf.addEventListener('change', function () {
            const d = bookingData[this.value];
            bookingChart.data.labels = d.labels;
            bookingChart.data.datasets[0].data = d.data;
            bookingChart.update();
        });
    }

    // ── Line Chart: Sales Trend ──
    const stEl = document.getElementById('salesTrendChart');
    if (stEl) {
        const stCtx = stEl.getContext('2d');
        const sg = stCtx.createLinearGradient(0,0,0,250);
        sg.addColorStop(0,'rgba(16,185,129,0.18)'); sg.addColorStop(1,'rgba(16,185,129,0)');

        new Chart(stCtx, {
            type: 'line',
            data: {
                labels: ['January','February','March','April','May'],
                datasets: [{ label:'Sales', data:[1200,1500,1800,1700,2100], borderColor:'#10b981', backgroundColor:sg, borderWidth:2.5, pointRadius:5, pointBackgroundColor:'#10b981', pointHoverRadius:7, tension:0.4, fill:true }]
            },
            options: {
                responsive: true,
                plugins: { legend:{display:false}, tooltip:{ backgroundColor:'#fff', titleColor:'#374151', bodyColor:'#6b7280', borderColor:'#e5e7eb', borderWidth:1, padding:10, callbacks:{ label: c => ` Sales: \u20b1${c.parsed.y.toLocaleString()}` } } },
                scales: { x:{grid:{display:false},ticks:{color:'#9ca3af',font:{family:'Montserrat',size:11}}}, y:{grid:{color:'#f3f4f6'},ticks:{color:'#9ca3af',font:{family:'Montserrat',size:11},callback: v => '\u20b1'+(v/1000).toFixed(1)+'K'}} }
            }
        });
    }

});
