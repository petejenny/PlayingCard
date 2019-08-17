//
//  ViewController.swift
//  PlayingCard
//
//  Created by Peter Forward on 8/12/19.
//  Copyright © 2019 Peter Forward. All rights reserved.
//

import UIKit

struct Constants {
    static var flipCardAnimationDuration: TimeInterval = 0.6
    static var matchCardAnimationDuration: TimeInterval = 0.6
    static var matchCardAnimationScaleUp: CGFloat = 3.0
    static var matchCardAnimationScaleDown: CGFloat = 0.1
    static var behaviorResistance: CGFloat = 0
    static var behaviorElasticity: CGFloat = 1.0
    static var behaviorPushMagnitudeMinimum: CGFloat = 0.5
    static var behaviorPushMagnitudeRandomFactor: CGFloat = 1.0
    static var cardsPerMainViewWidth: CGFloat = 5
}

class ViewController: UIViewController {
    
    private var deck = PlayingCardDeck()
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    @IBOutlet var cardViews: [PlayingCardView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cards = [PlayingCard]()
        
        for _ in 1...((cardViews.count+1)/2) {
            let card = deck.draw()!
            cards += [card, card]
            //            cards.append(card)
            //            cards.append(card)
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4Random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            cardBehavior.addItem(cardView)
        }
    }
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter{ $0.isFaceUp && !$0.isHidden } // && $0.transform != CGAffineTransform.identity.scaledBy(x: <#T##CGFloat#>, y: <#T##CGFloat#>)}
    }
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardViews.count == 2 &&
            faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
            faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    var lastChosenCardView: PlayingCardView?
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            // Make sure we don't flip if we already have 2 cards face up
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2 {
                lastChosenCardView = chosenCardView
                // Stop the flipped card moving
                cardBehavior.removeItem(chosenCardView)
                UIView.transition(with: chosenCardView,
                                  duration: 0.6,
                                  options: [.transitionFlipFromLeft],
                                  animations: {
                                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                },
                                  completion: { finished in
                                    // Make a local variable for the cards that are face up at this point in time
                                    let cardsToAnimate = self.faceUpCardViews
                                    if self.faceUpCardViewsMatch {
                                        // There are 2 cards and they match
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                            withDuration: 0.6,
                                            delay: 0,
                                            options: [],
                                            animations: {
                                                cardsToAnimate.forEach {
                                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                                }
                                        },
                                            completion: { position in
                                                UIViewPropertyAnimator.runningPropertyAnimator(
                                                    withDuration: 0.6,
                                                    delay: 0,
                                                    options: [],
                                                    animations: {
                                                        cardsToAnimate.forEach {
                                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                            $0.alpha = 0
                                                        }
                                                },
                                                    completion: { position in
                                                        cardsToAnimate.forEach {
                                                            $0.isHidden = true
                                                            // Is hidden.  But still clean up by setting alpha and transform
                                                            $0.alpha = 1
                                                            $0.transform = .identity
                                                        }
                                                }
                                                )
                                        }
                                        )
                                        
                                    }
                                    else if cardsToAnimate.count == 2 {
                                        if chosenCardView == self.lastChosenCardView {
                                            // There are 2 cards flipped and they don't match
                                            // Flip the cards face down and start them moving again
                                            cardsToAnimate.forEach { cardView in
                                                UIView.transition(with: cardView,
                                                                  duration: 0.6,
                                                                  options: [.transitionFlipFromRight],
                                                                  animations: {
                                                                    cardView.isFaceUp = false
                                                },
                                                                  completion: { finished in
                                                                    self.cardBehavior.addItem(cardView)
                                                }
                                                    
                                                )
                                            }
                                        }
                                    } else {
                                        // There is only 1 chosen card
                                        if !chosenCardView.isFaceUp {
                                            // Flipping over the 1 card
                                            self.cardBehavior.addItem(chosenCardView)
                                        }
                                    }
                }
                )
            }
        default:
            break
        }
    }
}
