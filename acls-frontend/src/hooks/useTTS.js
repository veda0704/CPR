import { useState, useRef, useEffect } from 'react';
import { getSpeechFromText } from '../services/api';
import { useTranslation } from 'react-i18next';

export const useTTS = () => {
  const { i18n } = useTranslation();
  const [speaking, setSpeaking] = useState(false);
  const audioRef = useRef(null);
  const requestIdRef = useRef(0);

  const stop = () => {
    // Increment request ID to cancel any pending async fetches
    requestIdRef.current += 1;
    
    // Stop native speech
    window.speechSynthesis.cancel();
    
    // Stop audio element
    if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current.currentTime = 0;
        audioRef.current = null;
    }
    setSpeaking(false);
  };

  const speak = async (text) => {
    if (!text) return;

    // Ensure we stop any current playback first
    stop();
    const myRequestId = requestIdRef.current;

    try {
      setSpeaking(true);
      const res = await getSpeechFromText(text, i18n.language);
      
      // If a new request was started or stop was called, abort
      if (myRequestId !== requestIdRef.current) return;

      const audioUrlRaw = res.data.audio_url;
      if (!audioUrlRaw) {
        throw new Error("No backend audio");
      }

      const fullUrl = audioUrlRaw.startsWith('http') 
        ? audioUrlRaw 
        : `http://${window.location.hostname}:8002${audioUrlRaw}`;

      const audio = new Audio(fullUrl);
      audioRef.current = audio;
      
      audio.onended = () => {
        if (myRequestId === requestIdRef.current) setSpeaking(false);
      };
      audio.onerror = () => {
        if (myRequestId === requestIdRef.current) setSpeaking(false);
      };

      await audio.play();

    } catch (err) {
      if (myRequestId !== requestIdRef.current) return;
      
      console.warn("Backend TTS failed, using native fallback:", err);
      // Fallback to Native
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = i18n.language === 'te' ? 'te-IN' : 'en-IN';
      utterance.onstart = () => {
        if (myRequestId === requestIdRef.current) setSpeaking(true);
      };
      utterance.onend = () => {
        if (myRequestId === requestIdRef.current) setSpeaking(false);
      };
      window.speechSynthesis.speak(utterance);
    }
  };

  useEffect(() => {
    return () => {
      // Clear anything on distruction
      stop();
    };
  }, []); // Only on unmount

  return { speak, stop, speaking };
};
