// Ô Ăn Quan — logic bàn cờ, vòng lặp trò chơi và AI 3 mức độ.
//
// Bố cục 12 ô theo vòng (chỉ số 0..11), thứ tự vòng đi theo chiều index tăng dần (nextAlive):
//   0  = Quan trái   (thuộc Bên A - người chơi)
//   1..5 = 5 ô dân của Bên A (người chơi), trái -> phải
//   6  = Quan phải   (thuộc Bên B - máy)
//   7..11 = 5 ô dân của Bên B (máy), và vòng nối 11 -> 0 khép kín hình chữ nhật.

const PLAYER = 'player';
const AI = 'ai';

const OWNER_DAN = {
  1: PLAYER, 2: PLAYER, 3: PLAYER, 4: PLAYER, 5: PLAYER,
  7: AI, 8: AI, 9: AI, 10: AI, 11: AI,
};
const QUAN_OWNER = { 0: PLAYER, 6: AI };
const PLAYER_DAN = [1, 2, 3, 4, 5];
const AI_DAN = [7, 8, 9, 10, 11];

function isQuan(i) { return i === 0 || i === 6; }

function initialCells() {
  const cells = new Array(12).fill(5);
  cells[0] = 10;
  cells[6] = 10;
  return cells;
}

function nextAlive(cells, dead, idx, dir) {
  let i = idx;
  do {
    i = (i + dir + 12) % 12;
  } while (dead[i]);
  return i;
}

// Thực hiện 1 lượt đi đầy đủ (rải + ăn liên hoàn). Trả về { cells, dead, captured, capturedCells: [...] }
function simulateMove(cells, dead, startIdx, dir, player) {
  cells = cells.slice();
  dead = dead.slice();

  let inHand = cells[startIdx];
  cells[startIdx] = 0;
  let current = startIdx;

  while (inHand > 0) {
    current = nextAlive(cells, dead, current, dir);
    cells[current] += 1;
    inHand -= 1;
    if (inHand === 0) {
      if (cells[current] > 1) {
        inHand = cells[current];
        cells[current] = 0;
      }
    }
  }

  let captured = 0;
  const capturedCells = [];
  let chainIdx = current;
  while (true) {
    const nIdx = nextAlive(cells, dead, chainIdx, dir);
    if (cells[nIdx] === 0) break;
    if (!isQuan(nIdx) && OWNER_DAN[nIdx] === player) break;
    captured += cells[nIdx];
    capturedCells.push(nIdx);
    cells[nIdx] = 0;
    if (isQuan(nIdx)) dead[nIdx] = true;
    chainIdx = nIdx;
  }

  return { cells, dead, captured, capturedCells, endIdx: current };
}

function legalMoves(cells, dead, player) {
  const danCells = player === PLAYER ? PLAYER_DAN : AI_DAN;
  const moves = [];
  for (const idx of danCells) {
    if (cells[idx] > 0) {
      moves.push({ idx, dir: 1 });
      moves.push({ idx, dir: -1 });
    }
  }
  return moves;
}

function hasAnyStones(cells, player) {
  const danCells = player === PLAYER ? PLAYER_DAN : AI_DAN;
  return danCells.some(i => cells[i] > 0);
}

// ---------------- Game state ----------------

let state = null;

function newGame() {
  state = {
    cells: initialCells(),
    dead: new Array(12).fill(false),
    scores: { [PLAYER]: 0, [AI]: 0 },
    turn: PLAYER,
    selected: null,
    over: false,
  };
  clearLog();
  log('Ván mới bắt đầu. Bạn đi trước.');
  render();
}

function log(msg) {
  const el = document.getElementById('log');
  const div = document.createElement('div');
  div.textContent = msg;
  el.prepend(div);
}

function clearLog() {
  document.getElementById('log').innerHTML = '';
}

// ---------------- Rendering ----------------

const boardEl = document.getElementById('board');
const dirPopup = document.getElementById('directionPopup');

// thứ tự hiển thị vật lý: hàng trên (máy) trái->phải = 11,10,9,8,7 ; hàng dưới (người) = 1,2,3,4,5
const TOP_ROW_DISPLAY = [11, 10, 9, 8, 7];
const BOTTOM_ROW_DISPLAY = [1, 2, 3, 4, 5];

function render() {
  boardEl.innerHTML = '';

  // ô quan trái (grid col 1, span 2 rows)
  boardEl.appendChild(makeCellEl(0));
  TOP_ROW_DISPLAY.forEach(idx => boardEl.appendChild(makeCellEl(idx)));
  boardEl.appendChild(makeCellEl(6));
  BOTTOM_ROW_DISPLAY.forEach(idx => boardEl.appendChild(makeCellEl(idx)));

  document.getElementById('scorePlayer').textContent = state.scores[PLAYER];
  document.getElementById('scoreAI').textContent = state.scores[AI];
  const turnIndicator = document.getElementById('turnIndicator');
  turnIndicator.textContent = state.over ? 'Ván đã kết thúc' : (state.turn === PLAYER ? 'Lượt của bạn' : 'Máy đang suy nghĩ...');
}

function makeCellEl(idx) {
  const div = document.createElement('div');
  div.className = 'cell';
  div.dataset.idx = idx;

  if (isQuan(idx)) {
    div.classList.add('quan');
    if (idx === 0) div.style.gridColumn = '1';
    if (idx === 6) div.style.gridColumn = '7';
  }

  if (state.dead[idx]) {
    div.classList.add('dead');
  } else {
    const count = state.cells[idx];
    const stonesToShow = Math.min(count, 12);
    for (let s = 0; s < stonesToShow; s++) {
      const stone = document.createElement('div');
      stone.className = 'stone';
      div.appendChild(stone);
    }
    const countLabel = document.createElement('span');
    countLabel.className = 'count';
    countLabel.textContent = count;
    div.appendChild(countLabel);
  }

  if (!isQuan(idx) && OWNER_DAN[idx] === PLAYER) {
    div.classList.add('player-owned');
    if (!state.over && state.turn === PLAYER && !state.dead[idx] && state.cells[idx] > 0) {
      div.classList.add('selectable');
      div.addEventListener('click', () => onCellClick(idx));
    }
  }

  if (state.selected === idx) {
    div.classList.add('selected');
  }

  return div;
}

function flashCells(indices) {
  indices.forEach(idx => {
    const el = boardEl.querySelector(`[data-idx="${idx}"]`);
    if (el) {
      el.classList.add('captured-flash');
      setTimeout(() => el.classList.remove('captured-flash'), 650);
    }
  });
}

// ---------------- Interaction ----------------

function onCellClick(idx) {
  if (state.over || state.turn !== PLAYER) return;
  state.selected = idx;
  render();
  showDirectionPopup(idx);
}

function showDirectionPopup(idx) {
  dirPopup.classList.remove('hidden');
}

function hideDirectionPopup() {
  dirPopup.classList.add('hidden');
}

dirPopup.addEventListener('click', (e) => {
  const btn = e.target.closest('button[data-dir]');
  if (!btn) return;
  const dir = parseInt(btn.dataset.dir, 10);
  const idx = state.selected;
  hideDirectionPopup();
  state.selected = null;
  performMove(idx, dir, PLAYER);
});

function performMove(idx, dir, player) {
  const result = simulateMove(state.cells, state.dead, idx, dir, player);
  state.cells = result.cells;
  state.dead = result.dead;
  state.scores[player] += result.captured;

  const who = player === PLAYER ? 'Bạn' : 'Máy';
  const dirLabel = dir === 1 ? 'phải' : 'trái';
  if (result.captured > 0) {
    log(`${who} rải ô ${idx} sang ${dirLabel}, ăn được ${result.captured} quân.`);
  } else {
    log(`${who} rải ô ${idx} sang ${dirLabel}, không ăn được quân nào.`);
  }

  render();
  if (result.capturedCells.length) flashCells(result.capturedCells);

  checkGameEnd(player === PLAYER ? AI : PLAYER);
}

function checkGameEnd(nextPlayer) {
  if (state.over) return;
  if (!hasAnyStones(state.cells, nextPlayer)) {
    endGame();
    return;
  }
  state.turn = nextPlayer;
  render();
  if (nextPlayer === AI) {
    setTimeout(aiTurn, 550);
  }
}

function endGame() {
  state.over = true;
  // cộng nốt quân còn lại trên bàn cho chủ ô
  for (const idx of PLAYER_DAN) {
    state.scores[PLAYER] += state.cells[idx];
    state.cells[idx] = 0;
  }
  for (const idx of AI_DAN) {
    state.scores[AI] += state.cells[idx];
    state.cells[idx] = 0;
  }
  if (!state.dead[0]) { state.scores[QUAN_OWNER[0]] += state.cells[0]; state.cells[0] = 0; state.dead[0] = true; }
  if (!state.dead[6]) { state.scores[QUAN_OWNER[6]] += state.cells[6]; state.cells[6] = 0; state.dead[6] = true; }

  render();
  log('Ván kết thúc.');
  showGameOver();
}

function showGameOver() {
  const modal = document.getElementById('gameOverModal');
  const title = document.getElementById('gameOverTitle');
  const text = document.getElementById('gameOverText');
  const p = state.scores[PLAYER];
  const a = state.scores[AI];
  if (p > a) {
    title.textContent = 'Bạn thắng!';
  } else if (a > p) {
    title.textContent = 'Máy thắng!';
  } else {
    title.textContent = 'Hoà!';
  }
  text.textContent = `Bạn: ${p} điểm — Máy: ${a} điểm.`;
  modal.classList.remove('hidden');
}

// ---------------- AI ----------------

function aiTurn() {
  const difficulty = document.getElementById('difficulty').value;
  const moves = legalMoves(state.cells, state.dead, AI);
  if (moves.length === 0) {
    checkGameEnd(PLAYER); // sẽ trigger endGame vì không còn nước đi
    return;
  }

  let move;
  if (difficulty === 'easy') {
    move = chooseRandom(moves);
  } else if (difficulty === 'medium') {
    move = chooseGreedy(moves);
  } else {
    move = chooseMinimax(moves);
  }

  performMove(move.idx, move.dir, AI);
}

function chooseRandom(moves) {
  return moves[Math.floor(Math.random() * moves.length)];
}

function chooseGreedy(moves) {
  let best = [];
  let bestScore = -Infinity;
  for (const m of moves) {
    const r = simulateMove(state.cells, state.dead, m.idx, m.dir, AI);
    if (r.captured > bestScore) {
      bestScore = r.captured;
      best = [m];
    } else if (r.captured === bestScore) {
      best.push(m);
    }
  }
  return chooseRandom(best);
}

function evaluate(cells, dead, scores) {
  const boardValue = (danList) => danList.reduce((s, i) => s + cells[i], 0);
  const myBoard = boardValue(AI_DAN) + (!dead[6] ? cells[6] : 0);
  const oppBoard = boardValue(PLAYER_DAN) + (!dead[0] ? cells[0] : 0);
  return (scores[AI] - scores[PLAYER]) + 0.5 * (myBoard - oppBoard);
}

function minimax(cells, dead, scores, player, depth, alpha, beta) {
  const moves = legalMoves(cells, dead, player);
  if (depth === 0 || moves.length === 0) {
    return { score: evaluate(cells, dead, scores) };
  }

  const maximizing = player === AI;
  let bestScore = maximizing ? -Infinity : Infinity;
  let bestMove = null;

  for (const m of moves) {
    const r = simulateMove(cells, dead, m.idx, m.dir, player);
    const newScores = { ...scores };
    newScores[player] += r.captured;
    const nextPlayer = player === AI ? PLAYER : AI;

    let result;
    if (!hasAnyStones(r.cells, nextPlayer)) {
      // ván sẽ kết thúc: quy đổi hết quân còn lại cho chủ ô để đánh giá chính xác hơn
      const finalScores = { ...newScores };
      for (const i of PLAYER_DAN) finalScores[PLAYER] += r.cells[i];
      for (const i of AI_DAN) finalScores[AI] += r.cells[i];
      if (!r.dead[0]) finalScores[PLAYER] += r.cells[0];
      if (!r.dead[6]) finalScores[AI] += r.cells[6];
      result = { score: finalScores[AI] - finalScores[PLAYER] };
    } else {
      result = minimax(r.cells, r.dead, newScores, nextPlayer, depth - 1, alpha, beta);
    }

    if (maximizing) {
      if (result.score > bestScore) {
        bestScore = result.score;
        bestMove = m;
      }
      alpha = Math.max(alpha, bestScore);
    } else {
      if (result.score < bestScore) {
        bestScore = result.score;
        bestMove = m;
      }
      beta = Math.min(beta, bestScore);
    }
    if (beta <= alpha) break;
  }

  return { score: bestScore, move: bestMove };
}

function chooseMinimax(moves) {
  const DEPTH = 5;
  const result = minimax(state.cells, state.dead, state.scores, AI, DEPTH, -Infinity, Infinity);
  return result.move || chooseRandom(moves);
}

// ---------------- Wiring ----------------

document.getElementById('newGameBtn').addEventListener('click', () => {
  document.getElementById('gameOverModal').classList.add('hidden');
  newGame();
});
document.getElementById('playAgainBtn').addEventListener('click', () => {
  document.getElementById('gameOverModal').classList.add('hidden');
  newGame();
});
document.getElementById('rulesBtn').addEventListener('click', () => {
  document.getElementById('rulesModal').classList.remove('hidden');
});
document.getElementById('closeRules').addEventListener('click', () => {
  document.getElementById('rulesModal').classList.add('hidden');
});

newGame();
