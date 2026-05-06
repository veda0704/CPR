import React, { useRef, useEffect } from 'react';

const createWaveform = (type) => {
    let components = [];
    
    switch (type) {
        case 'nsr': {
            const interval = 800;
            components = buildPQRST(interval);
            break;
        }
        case 'sinus_brady': {
            const interval = 1500;
            components = buildPQRST(interval);
            break;
        }
        case 'sinus_tachy': {
            const interval = 460;
            components = buildPQRST(interval);
            break;
        }
        case 'svt': {
             const interval = 330;
             components = buildNarrowComplex(interval);
             break;
        }
        case 'afib': {
             components = buildAFib();
             break;
        }
        case 'vtach': {
             const interval = 380;
             components = buildVTach(interval);
             break;
        }
        case 'vfib': {
             components = buildVFib();
             break;
        }
        case 'asystole': {
             components = buildAsystole();
             break;
        }
        case 'block_1st': {
             components = buildPQRST(800, { prExtension: 120 });
             break;
        }
        case 'block_2nd_type1': {
             components = buildWenckebach(800);
             break;
        }
        case 'block_2nd_type2': {
             components = buildMobitzII(800);
             break;
        }
        case 'block_3rd': {
             components = buildThirdDegree();
             break;
        }
        default:
            components = buildPQRST(800);
            break;
    }
    return components;
};

const buildPQRST = (intervalLength, options = {}) => {
    const prExt = options.prExtension || 0;
    return (timeMs) => {
        const t = timeMs % intervalLength;
        let y = 0;
        if (t > 50 && t < 150) {
            y -= Math.sin(((t - 50) / 100) * Math.PI) * 15;
        }
        const qrsStart = 200 + prExt;
        if (t > qrsStart && t < qrsStart + 20) {
            y += ((t - qrsStart) / 20) * 10;
        } else if (t >= qrsStart + 20 && t < qrsStart + 40) {
            y += 10 - (((t - (qrsStart + 20)) / 20) * 110);
        } else if (t >= qrsStart + 40 && t < qrsStart + 60) {
            y -= 100 - (((t - (qrsStart + 40)) / 20) * 110);
        } else if (t >= qrsStart + 60 && t < qrsStart + 80) {
             y += ((t - (qrsStart + 60)) / 20) * 10;
        } else if (t > qrsStart + 150 && t < qrsStart + 300) {
            y -= Math.sin(((t - (qrsStart + 150)) / 150) * Math.PI) * 20;
        }
        y += (Math.random() - 0.5) * 2;
        return y;
    };
};

const buildWenckebach = (baseInterval) => {
    const cycleLength = baseInterval * 4;
    return (timeMs) => {
        const t = timeMs % cycleLength;
        const beatIndex = Math.floor(t / baseInterval);
        const beatT = t % baseInterval;
        let y = 0;
        if (beatT > 50 && beatT < 150) {
            y -= Math.sin(((beatT - 50) / 100) * Math.PI) * 15;
        }
        if (beatIndex < 3) {
            const prExt = beatIndex * 60;
            const qrsStart = 200 + prExt;
            if (beatT > qrsStart && beatT < qrsStart + 20) {
                y += ((beatT - qrsStart) / 20) * 10;
            } else if (beatT >= qrsStart + 20 && beatT < qrsStart + 40) {
                y += 10 - (((beatT - (qrsStart + 20)) / 20) * 110);
            } else if (beatT >= qrsStart + 40 && beatT < qrsStart + 60) {
                y -= 100 - (((beatT - (qrsStart + 40)) / 20) * 110);
            } else if (beatT >= qrsStart + 60 && beatT < qrsStart + 80) {
                 y += ((beatT - (qrsStart + 60)) / 20) * 10;
            } else if (beatT > qrsStart + 150 && beatT < qrsStart + 300) {
                y -= Math.sin(((beatT - (qrsStart + 150)) / 150) * Math.PI) * 20;
            }
        }
        y += (Math.random() - 0.5) * 2;
        return y;
    }
}

const buildMobitzII = (baseInterval) => {
    const cycleLength = baseInterval * 3;
    return (timeMs) => {
        const t = timeMs % cycleLength;
        const beatIndex = Math.floor(t / baseInterval);
        const beatT = t % baseInterval;
        let y = 0;
        if (beatT > 50 && beatT < 150) {
            y -= Math.sin(((beatT - 50) / 100) * Math.PI) * 15;
        }
        if (beatIndex < 2) {
            const qrsStart = 200;
            if (beatT > qrsStart && beatT < qrsStart + 20) {
                y += ((beatT - qrsStart) / 20) * 10;
            } else if (beatT >= qrsStart + 20 && beatT < qrsStart + 40) {
                y += 10 - (((beatT - (qrsStart + 20)) / 20) * 110);
            } else if (beatT >= qrsStart + 40 && beatT < qrsStart + 60) {
                y -= 100 - (((beatT - (qrsStart + 40)) / 20) * 110);
            } else if (beatT >= qrsStart + 60 && beatT < qrsStart + 80) {
                 y += ((beatT - (qrsStart + 60)) / 20) * 10;
            } else if (beatT > qrsStart + 150 && beatT < qrsStart + 300) {
                y -= Math.sin(((beatT - (qrsStart + 150)) / 150) * Math.PI) * 20;
            }
        }
        y += (Math.random() - 0.5) * 2;
        return y;
    }
}

const buildThirdDegree = () => {
    const pInterval = 700;
    const qrsInterval = 1600;
    return (timeMs) => {
        let y = 0;
        const pT = timeMs % pInterval;
        if (pT > 50 && pT < 150) {
            y -= Math.sin(((pT - 50) / 100) * Math.PI) * 15;
        }
        const qT = timeMs % qrsInterval;
        const qrsStart = 100;
        if (qT > qrsStart && qT < qrsStart + 30) {
            y += ((qT - qrsStart) / 30) * 15;
        } else if (qT >= qrsStart + 30 && qT < qrsStart + 80) {
            y += 15 - (((qT - (qrsStart + 30)) / 50) * 120);
        } else if (qT >= qrsStart + 80 && qT < qrsStart + 130) {
            y -= 105 - (((qT - (qrsStart + 80)) / 50) * 120);
        } else if (qT >= qrsStart + 130 && qT < qrsStart + 160) {
             y += ((qT - (qrsStart + 130)) / 30) * 15;
        } else if (qT > qrsStart + 250 && qT < qrsStart + 450) {
            y += Math.sin(((qT - (qrsStart + 250)) / 200) * Math.PI) * 15;
        }
        y += (Math.random() - 0.5) * 2;
        return y;
    }
}

const buildNarrowComplex = (intervalLength) => {
    return (timeMs) => {
        const t = timeMs % intervalLength;
        let y = 0;
        if (t > 20 && t < 40) {
            y += ((t - 20) / 20) * 10;
        } else if (t >= 40 && t < 60) {
            y += 10 - (((t - 40) / 20) * 120);
        } else if (t >= 60 && t < 80) {
            y -= 110 - (((t - 60) / 20) * 120);
        } else if (t >= 80 && t < 100) {
             y += ((t - 80) / 20) * 10;
        } else if (t > 150 && t < 250) {
            y -= Math.sin(((t - 150) / 100) * Math.PI) * 15;
        }
        y += (Math.random() - 0.5) * 1.5;
        return y;
    }
}

const buildAFib = () => {
    const rrIntervals = [600, 450, 750, 500, 800, 550, 400];
    const totalTime = rrIntervals.reduce((a, b) => a + b, 0);
    return (timeMs) => {
        let t = timeMs % totalTime;
        let cumulative = 0;
        let offsetInInterval = 0;
        for (let i = 0; i < rrIntervals.length; i++) {
            if (t >= cumulative && t < cumulative + rrIntervals[i]) {
                offsetInInterval = t - cumulative;
                break;
            }
            cumulative += rrIntervals[i];
        }
        let y = 0;
        y += Math.sin(t * 0.05) * 5;
        y += Math.cos(t * 0.03) * 3;
        const qrsStart = 100;
        if (offsetInInterval > qrsStart && offsetInInterval < qrsStart + 20) {
             y += ((offsetInInterval - qrsStart) / 20) * 10;
        } else if (offsetInInterval >= qrsStart + 20 && offsetInInterval < qrsStart + 40) {
             y += 10 - (((offsetInInterval - (qrsStart + 20)) / 20) * 100);
        } else if (offsetInInterval >= qrsStart + 40 && offsetInInterval < qrsStart + 60) {
             y -= 90 - (((offsetInInterval - (qrsStart + 40)) / 20) * 100);
        } else if (offsetInInterval >= qrsStart + 60 && offsetInInterval < qrsStart + 80) {
             y += ((offsetInInterval - (qrsStart + 60)) / 20) * 10;
        } else if (offsetInInterval > qrsStart + 120 && offsetInInterval < qrsStart + 250) {
            y -= Math.sin(((offsetInInterval - (qrsStart + 120)) / 130) * Math.PI) * 15;
        }
        y += (Math.random() - 0.5) * 3;
        return y;
    }
}

const buildVTach = (intervalLength) => {
    return (timeMs) => {
        const t = timeMs % intervalLength;
        let y = 0;
        y = Math.sin((t / intervalLength) * Math.PI * 2) * -50;
        y += Math.cos((t / intervalLength) * Math.PI * 4) * 15;
        y += (Math.random() - 0.5) * 2;
        return y;
    }
}

const buildVFib = () => {
    return (timeMs) => {
        let y = 0;
        y += Math.sin(timeMs * 0.01) * 20;
        y += Math.sin(timeMs * 0.03) * 15;
        y += Math.cos(timeMs * 0.02) * 10;
        y += (Math.random() - 0.5) * 10;
        return y;
    }
}

const buildAsystole = () => {
    return (timeMs) => {
        let y = 0;
        y += Math.sin(timeMs * 0.001) * 2;
        y += (Math.random() - 0.5) * 3;
        return y;
    }
}

const formatRhythmName = (type) => {
    const titles = {
        nsr: 'Normal Sinus Rhythm',
        sinus_brady: 'Sinus Bradycardia',
        sinus_tachy: 'Sinus Tachycardia',
        svt: 'Supraventricular Tachycardia (SVT)',
        afib: 'Atrial Fibrillation',
        vtach: 'Ventricular Tachycardia',
        vfib: 'Ventricular Fibrillation',
        asystole: 'Asystole',
        block_1st: '1st Degree AV Block',
        block_2nd_type1: '2nd Degree AV Block (Wenckebach)',
        block_2nd_type2: '2nd Degree AV Block (Mobitz II)',
        block_3rd: '3rd Degree AV Block (Complete)',
    };
    return titles[type] || 'ECG Monitor';
};

const SingleMonitor = ({ rhythmType, isHero = false }) => {
    const canvasRef = useRef(null);

    useEffect(() => {
        const canvas = canvasRef.current;
        if (!canvas) return;
        const ctx = canvas.getContext('2d');
        let animationFrameId;
        const speed = 0.15;
        const yOffset = canvas.height / 2;
        const width = canvas.width;
        let timeOffset = 0;
        const waveformFunction = createWaveform(rhythmType);

        const render = (time) => {
            // Hero mode uses transparent background, normal mode uses charcoal
            if (isHero) {
                ctx.clearRect(0, 0, width, canvas.height);
            } else {
                ctx.fillStyle = '#1A1716'; 
                ctx.fillRect(0, 0, width, canvas.height);
            }
            
            // Grid lines
            ctx.lineWidth = 0.5;
            ctx.strokeStyle = isHero 
                ? 'color-mix(in srgb, var(--primary-color), transparent 90%)'
                : 'rgba(138, 63, 12, 0.15)'; 
            
            for(let i=0; i<width; i+=40) {
               ctx.beginPath(); ctx.moveTo(i, 0); ctx.lineTo(i, canvas.height); ctx.stroke();
            }
            for(let j=0; j<canvas.height; j+=40) {
               ctx.beginPath(); ctx.moveTo(0, j); ctx.lineTo(width, j); ctx.stroke();
            }

            // Waveform
            ctx.lineWidth = isHero ? 3.5 : 2.5;
            ctx.strokeStyle = isHero ? 'var(--primary-color)' : '#F2A007'; 
            ctx.lineJoin = 'round';
            ctx.beginPath();
            timeOffset = time;
            for (let x = width; x >= 0; x -= 2) {
                const timeAtX = timeOffset - ((width - x) / speed);
                if (timeAtX < 0) continue;
                const y = waveformFunction(timeAtX);
                if (x === width) {
                    ctx.moveTo(x, yOffset + y);
                } else {
                    ctx.lineTo(x, yOffset + y);
                }
            }
            ctx.stroke();

            // Fade effect at the leading edge
            if (!isHero) {
                const grad = ctx.createLinearGradient(width - 50, 0, width, 0);
                grad.addColorStop(0, 'rgba(26, 23, 22, 0)');
                grad.addColorStop(1, 'rgba(26, 23, 22, 1)');
                ctx.fillStyle = grad;
                ctx.fillRect(width - 50, 0, 50, canvas.height);
            }

            animationFrameId = requestAnimationFrame(render);
        };
        animationFrameId = requestAnimationFrame(render);
        return () => cancelAnimationFrame(animationFrameId);
    }, [rhythmType, isHero]);

    const monitorStyle = isHero ? {
        position: 'relative',
        width: '100%',
        background: 'transparent',
    } : {
        position: 'relative',
        width: '100%',
        marginBottom: '16px',
        borderRadius: '12px',
        overflow: 'hidden',
        border: '1.5px solid var(--border)',
        background: '#1A1716',
        boxShadow: '0 8px 30px rgba(0,0,0,0.2)'
    };

    return (
        <div style={monitorStyle}>
            {!isHero && (
                <>
                    <div style={{ position: 'absolute', top: '10px', left: '16px', color: '#F2A007', fontWeight: 900, fontSize: '14px', zIndex: 10, letterSpacing: '0.5px' }}>
                        II
                    </div>
                    <div style={{ position: 'absolute', top: '10px', right: '16px', color: 'rgba(233, 224, 179, 0.6)', fontWeight: 800, fontSize: '11px', zIndex: 10, textTransform: 'uppercase', letterSpacing: '1px' }}>
                        {formatRhythmName(rhythmType)}
                    </div>
                </>
            )}
            <canvas 
                ref={canvasRef} 
                width={800} 
                height={180} 
                style={{ width: '100%', height: 'auto', display: 'block' }}
            />
        </div>
    );
};

const AnimatedECG = ({ rhythms = ['nsr'], isHero = false }) => {
    return (
        <div style={{ display: 'flex', flexDirection: 'column', width: '100%', height: '100%', justifyContent: 'center', background: 'transparent', padding: isHero ? '0' : '16px', borderRadius: '16px' }}>
            {rhythms.map((rhythm, idx) => (
                <SingleMonitor key={idx} rhythmType={rhythm} isHero={isHero} />
            ))}
        </div>
    );
};

export default AnimatedECG;
