import React from 'react';
import './App.scss';
// eslint-disable-next-line max-len
import { PhoneAppAnalyzer } from './components/PhoneAppAnalyzer/PhoneAppAnalyzer';

export const misha = {
  name: 'Misha',
  age: 37,
  sex: 'm',
  isMarried: true,
  partnerName: 'Natasha',
};

export const olya = {
  name: 'Olya',
  sex: 'f',
  isMarried: true,
  partnerName: 'Maksym',
};

export const alex = {
  name: 'Alex',
  age: 25,
  sex: 'm',
  isMarried: false,
};

export const App = () => (
  <div className="App">
    <PhoneAppAnalyzer />
  </div>
);
